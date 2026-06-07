# Cachix cache

Use Cachix to prebuild expensive `rabanastre` outputs, such as the
linux-surface kernel, after flake input updates. The laptop can then substitute
from Cachix instead of compiling locally.

## Create the cache

Create a Cachix cache from the Cachix dashboard or CLI. A public cache is the
simplest fit for this repository.

Save these values:

- Cache name, without `.cachix.org`
- Public signing key
- Auth token with write access

Add the auth token to the GitHub repository as:

```text
CACHIX_AUTH_TOKEN
```

Add the cache name as a GitHub Actions repository variable:

```text
CACHIX_CACHE_NAME
```

## Enable the cache on rabanastre

After the cache exists, enable it in `hosts/rabanastre/default.nix`:

```nix
my.nixos.cachixCache = {
  enable = true;
  cacheName = "dawei-nixos";
  publicKey = "dawei-nixos.cachix.org-1:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
};
```

Apply once on `rabanastre`:

```sh
sudo nixos-rebuild switch --flake .#rabanastre --show-trace
```

## GitHub Actions flow

The workflow in `.github/workflows/cache-rabanastre.yml` runs when `flake.lock`
changes on a pushed commit. It also supports manual runs through
`workflow_dispatch`.

The workflow:

1. Installs Nix.
2. Configures the Cachix cache.
3. Builds `.#nixosConfigurations.rabanastre.config.boot.kernelPackages.kernel`.
4. Builds `.#nixosConfigurations.rabanastre.config.system.modulesTree`.
5. Pushes the kernel and module tree closures to Cachix.

This means cache work happens when dependencies move, rather than on a nightly
schedule.

## Manual cache push

From any Linux builder with the Cachix client configured:

```sh
nix build .#nixosConfigurations.rabanastre.config.boot.kernelPackages.kernel \
  --out-link result-kernel \
  --show-trace

nix build .#nixosConfigurations.rabanastre.config.system.modulesTree \
  --out-link result-modules \
  --show-trace

cachix push "$CACHIX_CACHE_NAME" result-kernel result-modules
```

## Validation

On `rabanastre`, verify the cache is configured:

```sh
nix show-config | rg 'substituters|trusted-public-keys'
```

Then rebuild:

```sh
sudo nixos-rebuild switch --flake .#rabanastre --show-trace
```

If the GitHub workflow has populated the cache for the current `flake.lock`,
Nix should download cached linux-surface outputs instead of rebuilding them.
