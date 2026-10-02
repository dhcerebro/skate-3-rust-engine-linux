#!/bin/sh
# One-time crate download for the locked-down Deck binaries.
# Run this on a guest network, then disable Wi-Fi and use ./BUILD.sh
# (--offline). Does not build Steam, the updater, or skate-steam-relay.
set -e
cd "$(dirname "$0")/.."
# Only the packages the offline game build needs. Workspace members that
# pull steamworks (skate-steam-relay) are not fetched.
cargo fetch --locked -p skate-game -p skate-xiso
echo "Crate sources are in the local Cargo registry cache. You can go offline and run ./BUILD.sh."
