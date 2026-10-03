#!/bin/sh
# Launch the locked-down release binary. Does not invoke Cargo (no crate fetch).
# SKATE_ASSETS may be the setup --base directory (with installation.json) or
# the inner installations/<id>/assets tree.
set -e
cd "$(dirname "$0")"
bin=./target/release/skate3rust
if [ ! -x "$bin" ]; then
    echo "Build first: ./setup.sh (guest Wi-Fi) then airplane mode and ./BUILD.sh" >&2
    exit 1
fi

resolve_assets() {
    dir=$1
    if [ -f "$dir/private/game.json" ]; then
        printf '%s\n' "$dir"
        return 0
    fi
    if [ -f "$dir/assets/private/game.json" ]; then
        printf '%s\n' "$dir/assets"
        return 0
    fi
    if [ -f "$dir/installation.json" ]; then
        rel=$(sed -n 's/.*"directory"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/p' "$dir/installation.json" | head -n 1)
        if [ -n "$rel" ] && [ -f "$dir/$rel/assets/private/game.json" ]; then
            printf '%s\n' "$dir/$rel/assets"
            return 0
        fi
    fi
    return 1
}

if [ -z "${SKATE_ASSETS-}" ]; then
    for candidate in "$HOME/skate3-assets" "$PWD/data"; do
        if resolved=$(resolve_assets "$candidate"); then
            SKATE_ASSETS=$resolved
            break
        fi
    done
fi
if [ -z "${SKATE_ASSETS-}" ]; then
    echo "Set SKATE_ASSETS to the setup --base directory (e.g. \$HOME/skate3-assets)" >&2
    echo "or to installations/<id>/assets. Example: SKATE_ASSETS=\$HOME/skate3-assets ./PLAY.sh" >&2
    exit 1
fi
resolved=$(resolve_assets "$SKATE_ASSETS") || {
    echo "No converted assets under $SKATE_ASSETS" >&2
    echo "Expected private/game.json, or installation.json from tools/setup.py --base." >&2
    echo "If setup finished, try:" >&2
    echo "  ls -d $SKATE_ASSETS/installations/*/assets" >&2
    exit 1
}
echo "PLAY.sh assets=$resolved"
echo "Steam Deck: if only pause works, hold ☰ (Start) 2s to leave desktop keyboard mode."
# Do not inherit Steam's SDL ignore-list; gilrs still sees evdev either way.
unset SDL_GAMECONTROLLER_IGNORE_DEVICES
export SDL_JOYSTICK_HIDAPI_STEAMDECK="${SDL_JOYSTICK_HIDAPI_STEAMDECK:-1}"
exec "$bin" --assets "$resolved" "$@"
