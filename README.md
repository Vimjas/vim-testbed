# Vim Testbed

[![Build Status](https://travis-ci.org/tweekmonster/vim-testbed.svg?branch=master)](https://travis-ci.org/tweekmonster/vim-testbed)
[![](https://badge.imagelayers.io/testbed/vim:latest.svg)](https://imagelayers.io/?images=testbed/vim:latest)

Because unit testing a Vim plugin is a pain in the ass.

[vader.vim](https://github.com/junegunn/vader.vim) provides a pretty
straightforward way to test Vim plugins.  But, you'll only be testing on the
version of Vim you have installed.  Then there's the issue of running automated
tests with Travis-CI where you have to either:

- Build Vim from source which takes an eternity, then run your tests.
- Use the version that came with Ubuntu 12.04 which means you're only testing
  your plugin's ability to run on 7.3.429.

With this base image, you can build the versions you need and reuse them in
future tests.

## Usage

The README is a work in progress.  Take a look in the `example` directory and
[ubuntu-vims](https://github.com/tweekmonster/ubuntu-vims).

You will need to create your own Dockerfile, build an image, then push it to
your [Docker Hub](https://hub.docker.com/) repository.

### Dockerfile

```Dockerfile
FROM testbed/vim:latest

RUN install_vim -tag v7.3.429 -name vim73 -py -build \
                -tag v7.4.052 -name vim74-trusty -build \
                -tag master -py2 -py3 -ruby -lua -build \
                -tag neovim:v0.2.0 -py2 -py3 -ruby -build \
                -tag neovim:master -py2 -py3 -ruby -build

```

The `install_vim` script builds one or more versions of Vim that you would like
to use for testing.  Each version should be terminated with a `-build` flag to
tell the script to start a build.

The following flags are available for each build:

Flag | Description
---- | -----------
`-tag` | The Vim/Neovim release.  It should be a valid tag/commit hash, with an optional GitHub repo prefix.  E.g. `master`, `neovim:master`, `neovim:v0.1.7`, or `username/neovim:branch`.
`-flavor` | The Vim flavor.  Either `vim` (default) or `neovim`.  If empty, it will be detected from `-tag`.
`-name` | The name to use for the binary's symlink.  It defaults to `$FLAVOR-$TAG`, e.g. `vim-master` or `neovim-v0.1.7`.
`-py` | Build with Python 2.
`-py3` | Build with Python 3.
`-ruby` | Build with Ruby.
`-lua` | Build with Lua (implied with Neovim 0.2.1+).

With `-flavor vim` (the default), all other arguments (up until `-build`) get
passed through to `./configure`, e.g. `--disable-FEATURE` etc.

### Build

```shell
docker build -t "your/repository" .
```

From here you can run your tests locally (as described below), push it to your
Docker Hub repository, or setup an [automated build](https://docs.docker.com/docker-hub/builds/).

### Run

```shell
docker run -it --rm -v $PWD:/testplugin -v $PWD/test:/home "your/repository" vim74 '+Vader! test/*'
```

The entry point for the container is a script that runs the named Vim version.
In this case `vim74`.  Arguments after the name is passed to Vim.

The entry point script prefixes your arguments with `-u /home/vimtest/vimrc -i NONE`.
They can be overridden with your arguments.

## Setup

The base image is created with automated testing in mind.  It is not meant to
be built every time you run tests.  An unprivileged user `vimtest` is used to
run Vim to prevent files from being written back to your work directory.  This
means that it won't be able to download/install plugins into a mapped volume.

To deal with this, your test `vimrc` could add known paths within the container
to `rtp`, and your `Dockerfile` could install the plugins into that location.

### /rtp.vim

This image provides a helper script that should be sourced at the top of your
vimrc:

```vim
source /rtp.vim
```

It will add `/home/vimtest/vim` and `/home/vimtest/vim/after` to the runtime
path, and search for plugins in `/home/vimtest/plugins`.

### Volumes

Two volumes are provided:

Volume | Description
------ | -----------
/home | The user directory.
/testplugin | The directory for your plugin.
