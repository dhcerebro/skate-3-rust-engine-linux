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
# Once, on a guest network (no sudo):
./setup.sh

# Then airplane mode and compile:
./BUILD.sh
SKATE_ASSETS=$HOME/skate3-assets ./PLAY.sh
```

`setup.sh` installs rustup, a micromamba toolchain under `$HOME/ccenv`
(override with `SKATE_DECK_PREFIX`), Python numpy/Pillow, and `cargo fetch
--locked`. It writes `.deck-env` for `BUILD.sh`. It does not compile the
game and does not download extract-xiso.

Equivalent Cargo invocation:

```sh
CARGO_NET_OFFLINE=true cargo build --release --locked --offline --no-default-features \
    -p skate-game --bin skate3rust -p skate-xiso
```

`PLAY.sh` will not invoke Cargo. It requires `SKATE_ASSETS` so the game never
spawns `support/skate3setup` or the updater helper.

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
an embedded copy of SDL_GameControllerDB, and users can override or extend
mappings via the standard `SDL_GAMECONTROLLERCONFIG` environment variable.

## macOS (Apple Silicon, untested by us)

Contributed from #7, tested by its author on an M3: on macOS wgpu's Vulkan
backend compiles behind `vulkan-portability` (MoltenVK), and materials use
the non-bindless path (`BUFFER_BINDING_ARRAY` disabled, because MoltenVK
lacks robustBufferAccess2). Launch with `MVK_CONFIG_FAST_MATH_ENABLED=0` —
with fast-math on, the depth prepass and the main pass disagree on skinned,
morphed customiser skaters and render them as black-and-white patches.
