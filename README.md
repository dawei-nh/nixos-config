# Nix Config

Flake-driven NixOS, nix-darwin, and Home Manager configuration for:

- `rabanastre`
- `valendia`
- `LT-US26-MAC-200`

## Common Commands

Format and check the flake:

```sh
nix fmt
nix flake check --show-trace
```

Build a host without switching:

```sh
nix build .#nixosConfigurations.valendia.config.system.build.toplevel --show-trace
nix build .#nixosConfigurations.rabanastre.config.system.build.toplevel --show-trace
nix build .#darwinConfigurations.LT-US26-MAC-200.system --show-trace
```

Switch a NixOS host:

```sh
sudo nixos-rebuild switch --flake .#rabanastre --show-trace
sudo nixos-rebuild switch --flake .#valendia --show-trace
```

Switch the Darwin host:

```sh
darwin-rebuild switch --flake .#LT-US26-MAC-200 --show-trace
```

Unfree packages are enabled in the flake/module configuration, so normal builds
do not need `NIXPKGS_ALLOW_UNFREE=1` or `--impure`.

## Coding Agents

Oh My Pi (`omp`) uses the hash-pinned upstream release binaries in
[pkgs/omp-bin.nix](pkgs/omp-bin.nix) on x86_64 Linux, ARM64 Linux, and Apple
Silicon macOS. Nix only installs the binary and supplies the Linux runtime
libraries; there is no Rust or Bun compilation. The upstream `omp` flake
provides the Home Manager settings module, with its source-building package
overridden on every host.

To update, change the version and per-platform SHA-256 hashes in that package
using the upstream release's `SHA256SUMS.txt`, then run `nix flake check` and
`nix build .#omp-bin`. Updating the `omp` flake input updates its settings
module, independently of the installed binary version.

Codex CLI (`codex`) is included in the shared `cli` package tier on every host
as a fallback. It uses the complete prebuilt release bundle from `codex-cli-nix`,
including `codex-package.json` and runtime resources required to bootstrap the
local app-server daemon. Loose release binaries are not sufficient.

To update Codex, run `nix flake update codex-cli-nix`, then check and build the
affected host before switching. Keep the complete bundle packaging when updating;
otherwise daemon startup fails with `this CLI has no complete local package`.

Codex desktop is installed on `rabanastre` and `valendia` only; the macOS setup
is unchanged. OpenAI now distributes Codex inside
[ChatGPT](https://chatgpt.com/download/). The shared NixOS desktop profile enables
the [codex-desktop-linux](https://github.com/ilysenko/codex-desktop-linux) module,
which repackages the hash-pinned official Linux bundle, adds the required nix-ld
workspace libraries, and installs the **ChatGPT Community** launcher
(`codex-desktop`). Optional community features and remote-control services remain
disabled; the desktop app uses its own bundled CLI.

Build it independently with `nix build .#codex-desktop`. To update, run
`nix flake update codex-desktop-linux`, then check and rebuild the affected host
before switching. Desktop updates are independent of the shared Codex CLI
fallback. Do not run another installation of the same desktop app concurrently
against its shared user profile.

## Zen Browser

The Linux desktop profile installs Zen through
[modules/home/features/zen.nix](modules/home/features/zen.nix). The pinned upstream
flake enables nixpkgs' `withFFmpeg` support, making H.264 playback and H.264
MediaSource support available for sites such as Twitch.

The Zen input was refreshed to 1.24b after the previous 1.23.3b release archive
failed its pinned SHA-256 check. To update, run `nix flake update zen-browser`,
then check and build the affected host before switching.

FFmpeg libraries are browser-local and do not downgrade system FFmpeg. Do not
use the Arch `/usr/local/lib` workaround from
[Zen issue #14889](https://github.com/zen-browser/desktop/issues/14889).

After rebuilding and switching the host, fully quit and relaunch Zen so its
media processes inherit the codec-enabled library path. A custom
`my.features.zen.package` override must supply its own codec-enabled wrapper.

## Binary Cache

Use Cachix to prebuild expensive `rabanastre` outputs, such as the
linux-surface kernel, after flake input updates. Once the cache is populated,
the laptop can use the normal `nixos-rebuild switch` command above instead of a
separate build directory.

See [docs/cachix-cache.md](docs/cachix-cache.md).
