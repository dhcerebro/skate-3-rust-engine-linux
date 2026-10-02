#!/bin/sh
# Launch the locked-down release binary. Does not invoke Cargo (no crate fetch).
set -e
cd "$(dirname "$0")"
bin=./target/release/skate3rust
if [ ! -x "$bin" ]; then
    echo "Build first with ./BUILD.sh (after ./tools/fetch-crates.sh on a guest network)." >&2
    exit 1
fi
if [ -z "${SKATE_ASSETS-}" ]; then
    echo "Set SKATE_ASSETS to the converted assets directory so setup/updater helpers are never spawned." >&2
    echo "Example: SKATE_ASSETS=/path/to/assets ./PLAY.sh" >&2
    exit 1
fi
exec "$bin" --assets "$SKATE_ASSETS" "$@"
