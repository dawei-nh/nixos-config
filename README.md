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
as a fallback. It uses the prebuilt native release binary from `codex-cli-nix`.

## Binary Cache

Use Cachix to prebuild expensive `rabanastre` outputs, such as the
linux-surface kernel, after flake input updates. Once the cache is populated,
the laptop can use the normal `nixos-rebuild switch` command above instead of a
separate build directory.

See [docs/cachix-cache.md](docs/cachix-cache.md).
