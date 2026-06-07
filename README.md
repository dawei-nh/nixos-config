# Nix Config

Flake-driven NixOS, nix-darwin, and Home Manager configuration for:

- `rabanastre`
- `valendia`
- `LT-US24-MAC-137`

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
nix build .#darwinConfigurations.LT-US24-MAC-137.system --show-trace
```

Switch a NixOS host:

```sh
sudo nixos-rebuild switch --flake .#rabanastre --show-trace
sudo nixos-rebuild switch --flake .#valendia --show-trace
```

Switch the Darwin host:

```sh
darwin-rebuild switch --flake .#LT-US24-MAC-137 --show-trace
```

Unfree packages are enabled in the flake/module configuration, so normal builds
do not need `NIXPKGS_ALLOW_UNFREE=1` or `--impure`.

## Binary Cache

Use Cachix to prebuild expensive `rabanastre` outputs, such as the
linux-surface kernel, after flake input updates. Once the cache is populated,
the laptop can use the normal `nixos-rebuild switch` command above instead of a
separate build directory.

See [docs/cachix-cache.md](docs/cachix-cache.md).
