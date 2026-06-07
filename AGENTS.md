# Repository Guidelines

## Project Structure & Module Organization

This repository is a flake-driven NixOS, nix-darwin, and Home Manager configuration. The main entry point is `flake.nix`, with host construction helpers in `lib/`. Host-specific system definitions live under `hosts/`, such as `hosts/rabanastre/`, `hosts/valendia/`, and `hosts/darwin/`. User-level configurations live in `home/dawei/`.

Reusable modules are split by target platform: `modules/nixos/`, `modules/darwin/`, and `modules/home/`. Home Manager feature modules are in `modules/home/features/`; platform profiles are in `modules/*/profiles/`. Custom packages are exposed from `pkgs/`. Documentation belongs in `docs/`.

## Build, Test, and Development Commands

Use the development shell when bootstrapping tools:

```sh
nix develop
```

Format all Nix files with the configured formatter:

```sh
nix fmt
```

Run flake evaluation and module checks:

```sh
nix flake check --show-trace
```

Build host outputs without switching:

```sh
nix build .#nixosConfigurations.valendia.config.system.build.toplevel --show-trace
nix build .#nixosConfigurations.rabanastre.config.system.build.toplevel --show-trace
nix build .#darwinConfigurations.LT-US24-MAC-137.system --show-trace
```

Switch only on the intended machine:

```sh
sudo nixos-rebuild switch --flake .#rabanastre --show-trace
darwin-rebuild switch --flake .#LT-US24-MAC-137 --show-trace
```

## Coding Style & Naming Conventions

Write Nix expressions in the style produced by `nix fmt` (`nixpkgs-fmt`). Prefer small modules with explicit option sets and imports over large monolithic files. Use lower-kebab-case for module filenames, feature names, and host-related files, for example `desktop-plasma.nix` or `linux-desktop.nix`. Keep host-only hardware and machine details inside `hosts/<name>/`; keep reusable behavior in `modules/`.

## Testing Guidelines

There is no separate unit test suite. Treat `nix flake check --show-trace` as the baseline validation for every change. For host or platform changes, also build the affected configuration before opening a PR. If a change touches Cachix or expensive host outputs, consult `docs/cachix-cache.md`.

## Commit & Pull Request Guidelines

The visible history currently uses concise, imperative commit messages such as `Add nixos configuration`. Follow that pattern: describe the change, not the process. Keep commits scoped to one logical update.

Pull requests should include a short summary, affected hosts or modules, and the validation commands run. Link related issues when applicable. Include screenshots only for visible desktop or UI changes, such as sketchybar or Plasma adjustments.

## Agent-Specific Instructions

Avoid switching live systems from automation unless the user requested it for the current host. Prefer build and check commands for verification.
