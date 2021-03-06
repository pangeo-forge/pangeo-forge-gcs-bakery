#!/bin/bash
function cleanup {
  echo "Removing diffs"
  rm -f /tmp/before
  rm -f /tmp/after
}

trap cleanup EXIT

echo "------------------------------------------"
echo "       Pangeo Forge - GCE bakery"
echo "       ----  PREPARE SCRIPT ----"
echo "------------------------------------------"
echo "- Checking prerequisites..."
echo ".env path set as $1/.env"
if [[ ! -f $1/.env ]]; then
  echo ".env file not found"
  exit 1
fi

env > /tmp/before
set -a
[[ -f $1/.env ]] && source "$1/.env"
env > /tmp/after
echo "This script added the following variables:"
diff -y /tmp/before /tmp/after | grep '>'
echo "------------------------------------------"
echo "            Prepare - All done!           "
echo "------------------------------------------"