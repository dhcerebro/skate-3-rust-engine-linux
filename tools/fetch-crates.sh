#!/bin/sh
# One-time crate download for an offline ./BUILD.sh.
# Run this on a guest network, then disable Wi-Fi.
#
# cargo fetch has no package filter. This pulls the workspace lockfile
# (including unused Steam crate sources). BUILD.sh still does not compile
# skate-steam-relay, the updater, or --features network/steam.
set -e
cd "$(dirname "$0")/.."
cargo fetch --locked
echo "Crate sources are in the local Cargo registry cache. You can go offline and run ./BUILD.sh."
