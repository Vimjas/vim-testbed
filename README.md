# Vim Testbed

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

The README is a work in progress.  Take a look in the `example` directory.

You will need to create your own Dockerfile, build an image, then push it to
your [Docker Hub](https://hub.docker.com/) repository.

### Dockerfile

```Dockerfile
FROM tweekmonster/vim-testbed:latest

RUN install_vim -tag v7.3 -name vim73 -build \
                -tag v7.4.052 -name vim74 -build \
                -tag master -build
```

The `install_vim` script builds one or more versions of Vim that you would like
to use for testing.  Each version should be terminated with a `-build` flag to
tell the script to start a build.

The following flags can be used for each build:

Flag | Description
---- | -----------
`-tag` | The Vim release.  It must match the tags on Vim's [releases page](https://github.com/vim/vim/releases).
`-name` | The name to use for the binary's symlink.  If omitted, the name will default to `vim-$TAG`.
`-py` | Build with Python 2.  Can't be used with `-py3`.
`-py3` | Build with Python 3.  Can't be used with `-py`.
`-ruby` | Build with Ruby.
`-lua` | Build with Lua.


### Build

```shell
docker build -t "your/repository" .
```

From here you can run your tests locally (as described below), push it to your
Docker Hub repository, or setup an [automated build](https://docs.docker.com/docker-hub/builds/).

### Run

```shell
docker run -it --rm -v $(PWD):/testplugin -v $(PWD)/test:/home "your/repository" vim74 '+Vader! test/*'
```

The entry point for the container is a script that runs the named Vim version.
In this case `vim74`.  Arguments after the name is passed to Vim.

The entry point script prefixes your arguments with `-u /home/vimrc -i NONE`.
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

It will add `/home/vim` and `/home/vim/after` to the runtime path, and search
for plugins in `/home/plugins`.


### Volumes

Two volumes are provided:

Volume | Description
------ | -----------
/home | The user directory.
/testplugin | The directory for your plugin.
