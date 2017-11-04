#!/bin/sh

if [ "$VIM_TESTBED_DEBUG" = 1 ]; then
  set -x
fi

BIN=$1
shift

if [ "$BIN" = "sh" ] || [ -z "$BIN" ]; then
  exec /bin/sh
fi
if ! [ -x "/vim-build/bin/$BIN" ]; then
  exec "$BIN" "$@"
fi

# Set default vimrc to a visible file
ARGS="-u /home/vimtest/vimrc -i NONE"

# So we can pass the arguments to Vim as it was passed to this script
while [ $# -gt 0 ]; do
  ARGS="$ARGS \"$1\""
  shift
done

# Run as the vimtest user.  This is not really for security.  It is for running
# Vim as a user that's unable to write to your volume.
exec su -l vimtest -c "cd /testplugin && /vim-build/bin/$BIN $ARGS"
