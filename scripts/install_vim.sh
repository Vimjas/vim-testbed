#!/bin/bash

set -e

bail() {
  echo "$@"
  exit 1
}


TAG=""
NAME=""
PYTHON=0
RUBY=0
LUA=0

build() {
  [ -z $NAME ] && NAME="vim-${TAG}"
  [ -z $TAG ] && bail "-tag is required"

  VIM_NAME="vim_${TAG}_py${PYTHON}_rb${RUBY}_lua${LUA}"
  VIM_PATH="/vim-build/$VIM_NAME"
  VIM_BIN="$VIM_PATH/bin/vim"

  CONFIG_ARGS="--prefix=$VIM_PATH --enable-multibyte --without-x --enable-gui=no --with-compiledby=vim-testbed"

  if [ $PYTHON -eq 2 ]; then
    CONFIG_ARGS="$CONFIG_ARGS --enable-pythoninterp"
    apk add python-dev
  fi

  if [ $PYTHON -eq 3 ]; then
    CONFIG_ARGS="$CONFIG_ARGS --enable-python3interp=dynamic"
    apk add python3-dev
  fi

  if [ $RUBY -eq 1 ]; then
    CONFIG_ARGS="$CONFIG_ARGS --enable-rubyinterp"
    apk add ruby-dev
  fi

  if [ $LUA -eq 1 ]; then
    CONFIG_ARGS="$CONFIG_ARGS --enable-luainterp"
    apk add lua-dev
  fi

  cd /vim

  BUILD_DIR="vim-${TAG#v}"

  apk info -q vim-build > /dev/null || apk add --virtual vim-build make ncurses-dev curl gcc libc-dev

  if [ ! -d $BUILD_DIR ]; then
    # The git package adds about 200MB+ to the image.  So, no cloning.
    echo "Downloading $TAG"
    curl -SL "https://github.com/vim/vim/archive/${TAG}.tar.gz" | tar zx
  fi

  cd $BUILD_DIR
  echo "Configuring with: $CONFIG_ARGS"
  # shellcheck disable=SC2086
  ./configure $CONFIG_ARGS || bail "Could not configure"
  make CFLAGS="-U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2" -j4 || bail "Make failed"
  make install || bail "Install failed"

  ln -s $VIM_BIN /vim-build/bin/$NAME

  # Clean, but don't delete the source in case you want make a different build
  # with the same version.
  make distclean
}


apk update

while [ $# -gt 0 ]; do
  case $1 in
    -name)
      NAME="$2"
      shift
      ;;
    -tag)
      TAG="$2"
      shift
      ;;
    -py)
      PYTHON=2
      ;;
    -py3)
      PYTHON=3
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
      build
      NAME=""
      TAG=""
      PYTHON=0
      RUBY=0
      LUA=0
      ;;
  esac

  shift
done

apk del vim-build
rm -rf /vim/*
rm -rf /var/cache/apk/* /tmp/* /var/tmp/*
