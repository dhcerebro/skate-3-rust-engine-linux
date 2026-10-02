#!/bin/sh
# Steam Deck / paranoid Linux build: no Steam, no updater, no sockets,
# and Cargo is forced offline so it cannot fetch crates during the compile.
#
# One-time guest-network step first: ./tools/fetch-crates.sh
set -e
cd "$(dirname "$0")"
case " $* ${CARGO_FEATURES-} ${CARGO_TERM_FEATURES-}" in
    *network*|*steam*)
        echo "Refusing a networked/Steam feature set. This script is offline-only." >&2
        exit 1
        ;;
esac
if [ "$(ldd --version 2>&1 | grep -ci musl)" -gt 0 ]; then
    export RUSTFLAGS="${RUSTFLAGS:+$RUSTFLAGS }-C target-feature=-crt-static"
fi
export CARGO_NET_OFFLINE=true
cargo build --release --locked --offline --no-default-features \
    -p skate-game --bin skate3rust \
    -p skate-xiso
echo "Built target/release/skate3rust and target/release/skate-xiso (network compiled out)."
