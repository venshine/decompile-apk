#!/bin/sh
set -e
SCRIPT_DIR="$(cd "$(dirname "$0")"/.. && pwd)"
cd "$SCRIPT_DIR"

# Create a temporary working directory
TMPDIR=$(mktemp -d)
cd "$TMPDIR"

# Prepare a fake apk file
echo "dummy" > sample.apk

# Source util.sh and run check
. "$SCRIPT_DIR/util.sh"
check sample.apk

# Validate generated variables
[ "$filename" = "sample.apk" ] || exit 1
[ "$foldername" = "sample" ] || exit 1
[ "$(basename "$PWD")" = "output" ] || exit 1

cd "$SCRIPT_DIR"
rm -rf "$TMPDIR"


