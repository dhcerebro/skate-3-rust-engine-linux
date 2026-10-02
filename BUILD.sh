#!/bin/sh
# Offline compile. Run ./setup.sh on guest Wi-Fi first, then airplane mode.
set -e
cd "$(dirname "$0")"
case " $* ${CARGO_FEATURES-} ${CARGO_TERM_FEATURES-}" in
    *network*|*steam*)
        echo "Refusing a networked/Steam feature set. This script is offline-only." >&2
        exit 1
        ;;
esac
if [ -f "$PWD/.deck-env" ]; then
    # shellcheck disable=SC1091
    . "$PWD/.deck-env"
elif [ -f "$HOME/.cargo/env" ]; then
    # shellcheck disable=SC1091
    . "$HOME/.cargo/env"
fi
if ! command -v cc >/dev/null 2>&1; then
    echo "linker 'cc' not found. On guest Wi-Fi run: ./setup.sh" >&2
    exit 1
fi
if ! command -v pkg-config >/dev/null 2>&1; then
    echo "pkg-config not found. On guest Wi-Fi run: ./setup.sh" >&2
    exit 1
fi
if [ "$(ldd --version 2>&1 | grep -ci musl)" -gt 0 ]; then
    export RUSTFLAGS="${RUSTFLAGS:+$RUSTFLAGS }-C target-feature=-crt-static"
fi
export CARGO_NET_OFFLINE=true
cargo build --release --locked --offline --no-default-features \
    -p skate-game --bin skate3rust \
    -p skate-xiso
echo "Built target/release/skate3rust and target/release/skate-xiso (network compiled out)."
