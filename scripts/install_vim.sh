#!/bin/sh

set -e
set -x

bail() {
  echo "$@" >&2
  exit 1
}

init_vars() {
  FLAVOR=
  TAG=
  NAME=
  PYTHON2=
  PYTHON3=
  RUBY=0
  LUA=0
  CONFIGURE_OPTIONS=
}

build() {
  [ -z $TAG ] && bail "-tag is required"

  # Parse TAG into repo and tag.
  IFS=: read -r -- repo tag <<EOF
$TAG
EOF
  if [ -z "$tag" ]; then
    tag="$repo"
    repo=
  elif [ "$repo" = vim ]; then
    repo="vim/vim"
  elif [ "$repo" = neovim ]; then
    repo="neovim/neovim"
    [ -z "$FLAVOR" ] && FLAVOR=neovim
  elif [ "${repo#*/}" = "$repo" ]; then
    bail "Unrecognized repo ($repo) from tag: $TAG"
  elif [ "${repo#*/neovim}" != "$repo" ]; then
    FLAVOR=neovim
  fi
  if [ -z "$FLAVOR" ]; then
    FLAVOR=vim
  fi
  if [ -z "$repo" ]; then
    if [ "$FLAVOR" = vim ]; then
      repo="vim/vim"
    else
      repo="neovim/neovim"
    fi
  fi
  [ -z $NAME ] && NAME="${FLAVOR}-${tag}"

  if [ "$FLAVOR" = vim ]; then
    VIM_NAME="${repo}/${tag}_py${PYTHON2}${PYTHON3}_rb${RUBY}_lua${LUA}"
  else
    VIM_NAME="${repo}/${tag}"
  fi
  INSTALL_PREFIX="/vim-build/$VIM_NAME"

  if [ "$FLAVOR" = vim ]; then
    CONFIG_ARGS="--prefix=$INSTALL_PREFIX --enable-multibyte --without-x --enable-gui=no --with-compiledby=vim-testbed"
  fi
  set +x
  echo "TAG:$TAG"
  echo "repo:$repo"
  echo "tag:$tag"
  echo "FLAVOR:$FLAVOR"
  echo "NAME:$NAME"
  set -x

  apk add --virtual vim-build curl gcc libc-dev make

  if [ -n "$PYTHON2" ]; then
    apk add --virtual vim-build python-dev
    if [ "$FLAVOR" = vim ]; then
      CONFIG_ARGS="$CONFIG_ARGS --enable-pythoninterp=dynamic"
    else
      apk add --virtual vim-build py2-pip
      apk add python
      pip2 install neovim
    fi
  fi

  if [ -n "$PYTHON3" ]; then
    apk add --virtual vim-build python3-dev
    if [ "$FLAVOR" = vim ]; then
      CONFIG_ARGS="$CONFIG_ARGS --enable-python3interp=dynamic"
    else
      apk add python3
      pip3 install neovim
    fi
  fi

  if [ $RUBY -eq 1 ]; then
    apk add --virtual vim-build ruby-dev
    apk add ruby
    if [ "$FLAVOR" = vim ]; then
      CONFIG_ARGS="$CONFIG_ARGS --enable-rubyinterp"
    else
      apk add --virtual vim-build ruby-rdoc ruby-irb
      gem install neovim
    fi
  fi

  if [ $LUA -eq 1 ]; then
    if [ "$FLAVOR" = vim ]; then
      CONFIG_ARGS="$CONFIG_ARGS --enable-luainterp"
      apk add --virtual vim-build lua-dev
      apk add lua
    else
      echo 'WARNING: -lua is not supported with Neovim, ignoring.'
    fi
  fi

  if [ "$FLAVOR" = vim ] && [ -n "$CONFIGURE_OPTIONS" ]; then
    CONFIG_ARGS="$CONFIG_ARGS $CONFIGURE_OPTIONS"
  fi

  cd /vim

  if [ -d "$INSTALL_PREFIX" ]; then
    echo "WARNING: $INSTALL_PREFIX exists already.  Overwriting."
  fi

  BUILD_DIR="${FLAVOR}-${repo}-${tag}"
  if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p "$BUILD_DIR"
    cd "$BUILD_DIR"
    # The git package adds about 200MB+ to the image.  So, no cloning.
    url="https://github.com/$repo/archive/${tag}.tar.gz"
    echo "Downloading $repo:$tag from $url"
    curl -SL "$url" | tar zx --strip-components=1
  else
    cd "$BUILD_DIR"
  fi

  if [ "$FLAVOR" = vim ]; then
    apk add --virtual vim-build ncurses-dev
    apk add ncurses

    echo "Configuring with: $CONFIG_ARGS"
    # shellcheck disable=SC2086
    ./configure $CONFIG_ARGS || bail "Could not configure"
    make CFLAGS="-U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2" -j4 || bail "Make failed"
    make install || bail "Install failed"

  elif [ "$FLAVOR" = neovim ]; then
    # Some of them will be installed already, but it is a good reference for
    # what is required.
    apk add libuv \
      libtermkey \
      libvterm \
      msgpack-c \
      unibilium
    apk add --virtual vim-build \
      autoconf \
      automake \
      ca-certificates \
      cmake \
      g++ \
      gperf \
      libtool \
      libuv-dev \
      libtermkey-dev \
      libvterm-dev \
      luajit \
      luajit-dev \
      m4 \
      make \
      msgpack-c-dev \
      perl \
      unzip \
      unibilium-dev \
      xz

    # Install luarocks manually for Alpine's luajit.
    # I could not make it work through LUAROCKS_OPTS in DEPS_CMAKE_FLAGS.
    ( cd /tmp
      curl -SL https://luarocks.org/releases/luarocks-2.4.1.tar.gz | tar zxp
      cd luarocks-*
      ./configure --lua-suffix=jit --with-lua-bin=/usr/bin/luajit \
        --with-lua-include=/usr/include/luajit-2.1
      make bootstrap
      for rock in lpeg mpack; do
        luarocks install $rock
      done
      rm /usr/local/bin/luarocks*
      rm -rf /usr/local/share/lua/5*/luarocks
      rm -rf /usr/local/etc/luarocks*
    )

    make CMAKE_BUILD_TYPE=RelWithDebInfo \
      CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX \
        -DENABLE_JEMALLOC=OFF" \
      DEPS_CMAKE_FLAGS="-DUSE_BUNDLED=OFF" \
        || bail "Make failed"

    versiondef_file=build/config/auto/versiondef.h
    if grep -qF '#define NVIM_VERSION_PRERELEASE "-dev"' $versiondef_file \
        && grep -qF '/* #undef NVIM_VERSION_MEDIUM */' $versiondef_file ; then

      head_info=$(curl -SL "https://api.github.com/repos/$repo/git/refs/heads/$tag")
      if [ -n "$head_info" ]; then
        head_sha=$(echo "$head_info" | grep '"sha":' | cut -f4 -d\" | cut -b -7)
        if [ -n "$head_sha" ]; then
          sed -i "s/#define NVIM_VERSION_PRERELEASE \"-dev\"/#define NVIM_VERSION_PRERELEASE \"-dev-$head_sha\"/" $versiondef_file
        fi
      fi
    fi
    make install || bail "Install failed"
  else
    bail "Unexpected FLAVOR: $FLAVOR (use vim or neovim)."
  fi

  # Clean, but don't delete the source in case you want make a different build
  # with the same version.
  make distclean

  if [ "$FLAVOR" = vim ]; then
    VIM_BIN="$INSTALL_PREFIX/bin/vim"
  else
    VIM_BIN="$INSTALL_PREFIX/bin/nvim"
  fi
  link_target="/vim-build/bin/$NAME"
  if [ -e "$link_target" ]; then
    echo "WARNING: link target for $NAME exists already.  Overwriting."
  fi
  ln -sfn "$VIM_BIN" "$link_target"
  "$link_target" --version
}

apk update

init_vars
while [ $# -gt 0 ]; do
  case $1 in
    -flavor)
      if [ "$2" != vim ] && [ "$2" != neovim ]; then
        bail "Invalid value for -flavor: $2: only vim or neovim are recognized."
      fi
      FLAVOR="$2"
      shift
      ;;
    -name)
      NAME="$2"
      shift
      ;;
    -tag)
      TAG="$2"
      shift
      ;;
    -py|-py2)
      PYTHON2=2
      ;;
    -py3)
      PYTHON3=3
      ;;
    -ruby)
      RUBY=1
      ;;
    -lua)
      LUA=1
      ;;
    -build)
      # So here I am thinking that using Alpine was going to give the biggest
      # savings in image size.  Alpine starts at about 5MB.  Built this image,
      # and it's about 8MB.  Looking good.  Install two versions of vanilla
      # vim, 300MB wtf!!!  Each run of this script without cleaning up created
      # a layer with all of the build dependencies.  So now, this script
      # expects a -build flag to signal the start of a build.  This way,
      # installing all Vim versions becomes one layer.
      # Side note: tried docker-squash and it didn't seem to do anything.
      echo "=== building: NAME=$NAME, TAG=$TAG, PYTHON=${PYTHON2}${PYTHON3}, RUBY=$RUBY, LUA=$LUA, FLAVOR=$FLAVOR ==="
      build
      init_vars
      ;;
    *)
      CONFIGURE_OPTIONS="$CONFIGURE_OPTIONS $1"
      ;;
  esac

  shift
done

echo "Pruning packages and dirs.."
apk info -q vim-build > /dev/null && apk del vim-build
rm -rf /vim/*
rm -rf /var/cache/apk/* /tmp/* /var/tmp/* /root/.cache
find / \( -name '*.pyc' -o -name '*.pyo' \) -delete
