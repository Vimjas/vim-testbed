#!/bin/bash

BIN=$1
shift

if [ "$BIN" == "bash" ] || [ -z "$BIN" ]; then
  exec /bin/bash
fi
if [ -n "$(/usr/bin/which "$BIN")" ]; then
  exec "$BIN" "$@"
fi

# Set default vimrc to a visible file
ARGS="-u /home/vimrc -i NONE"

# So we can pass the arguments to Vim as it was passed to this script
while [ $# -gt 0 ]; do
  ARGS="$ARGS \"$1\""
  shift
done

# Run as the vimtest user.  This is not really for security.  It is for running
# Vim as a user that's unable to write to your volume.
cd /testplugin || exit
exec su -l vimtest -c "env HOME=/tmp/vimtestbed-home /vim-build/bin/$BIN $ARGS"
