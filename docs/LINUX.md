# Linux build

The game builds and runs on Linux (glibc and musl). Vulkan is required;
wgpu uses the system Vulkan driver (Mesa RADV, NVIDIA, etc.).

## System dependencies

- wayland / libxcb / libxkbcommon (winit)
- alsa-lib (audio)
- libudev / eudev (gamepad enumeration via gilrs)
- clang + libclang (bindgen in dependency build scripts)

## Build (offline / Steam Deck)

Default features compile out GitHub updates, UDP multiplayer, and Steam.
`BUILD.sh` also sets `CARGO_NET_OFFLINE=true` so Cargo cannot fetch crates
while compiling.

```sh
# Safer (read the script, then run it):
git clone https://github.com/dhcerebro/skate-3-rust-engine-linux.git
cd skate-3-rust-engine-linux
./steamdeck_setup.sh
# prompted for an Xbox 360 .iso or default.xex (not PS3)
SKATE_ASSETS=$HOME/skate3-assets ./PLAY.sh
```

`./setup.sh` is a wrapper for `steamdeck_setup.sh`. That script installs rustup,
a micromamba toolchain under `$HOME/ccenv` (`libudev`, not `eudev`; no sudo),
Python numpy/Pillow, `cargo fetch --locked` (no `-p`), then compiles
`skate3rust` + `skate-xiso` offline, extracts a 360 ISO with the workspace
extractor, and converts assets. Pass `--source /path/to.iso` to skip the
prompt, `--toolchain-only` for fetch-only.

Piped one-liner (clones, then re-execs from the checkout so prompts use the TTY).
Until this is on `main`, pin the branch that has the script:

```sh
export SKATE_DECK_BRANCH=cursor/offline-deck-build-f946
curl -fsSL https://raw.githubusercontent.com/dhcerebro/skate-3-rust-engine-linux/${SKATE_DECK_BRANCH}/steamdeck_setup.sh | sh
```

Equivalent Cargo invocation:

```sh
CARGO_NET_OFFLINE=true cargo build --release --locked --offline --no-default-features \
    -p skate-game --bin skate3rust -p skate-xiso
```

`PLAY.sh` will not invoke Cargo. `SKATE_ASSETS` may be the `tools/setup.py --base`
directory (`installation.json`) or the inner `installations/<id>/assets` tree.

Networking can only be turned back on by passing `--features network` or
`--features network,steam` to Cargo. `BUILD.sh` refuses those feature names.

Notes:

- **musl**: rustup's musl target defaults to static-pie, but musl distros
  generally do not ship static wayland/alsa libraries. BUILD.sh detects musl
  via `ldd` and exports `RUSTFLAGS="-C target-feature=-crt-static"` to link
  dynamically against musl.
- **Setup**: run `tools/setup.py` with system Python (numpy/pillow/tkinter)
  against an extracted Xbox 360 `default.xex` folder, or a locally built
  `skate-xiso`. The extract-xiso GitHub download is disabled.
- **ISO extraction**: `skate-xiso` (workspace crate, xdvdfs-based) extracts
  Xbox 360 ISOs. Set `SKATE_XISO` if the binary is not under `target/`.

## Gamepads

Non-Windows input uses gilrs with its default filters disabled (raw axes,
matching what the TU3 input converter expects). Controller layouts come from
an embedded copy of SDL_GameControllerDB, plus extra Steam Deck GUID versions.
Users can override mappings via `SDL_GAMECONTROLLERCONFIG`.

On Steam Deck **desktop mode**, Steam's background client puts the built-in
pad in keyboard/mouse layout ("lizard mode"). Escape/Start still open the
pause menu; sticks do nothing. Hold **☰ (Start) for about two seconds** to
switch to the gamepad action set. `PLAY.sh` prints this hint. The runtime
prefers a mapped Steam Deck / Xbox node over touchpad/keyboard evdev devices.

## macOS (Apple Silicon, untested by us)

Contributed from #7, tested by its author on an M3: on macOS wgpu's Vulkan
backend compiles behind `vulkan-portability` (MoltenVK), and materials use
the non-bindless path (`BUFFER_BINDING_ARRAY` disabled, because MoltenVK
lacks robustBufferAccess2). Launch with `MVK_CONFIG_FAST_MATH_ENABLED=0` —
with fast-math on, the depth prepass and the main pass disagree on skinned,
morphed customiser skaters and render them as black-and-white patches.
