{
  description = "Dawei's NixOS";

  nixConfig = {
    extra-substituters = [
      "https://nix-community.cachix.org"
      "https://cache.nixos.org"
      "https://ezkea.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "ezkea.cachix.org-1:ioBmUbJTZIKsHmWWXPe1FSFbeVe+afhfgqgTSNd34eI="
    ];
  };

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    omp-nix = {
      url = "git+https://git.molez.org/mandlm/omp-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    codex-cli-nix = {
      url = "github:sadjow/codex-cli-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    impermanence = {
      url = "github:nix-community/impermanence/home-manager-v1";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs-firefox-darwin = {
      url = "github:bandithedoge/nixpkgs-firefox-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:youwen5/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    xivlauncher-rb = {
      url = "github:dawei-nh/xivlauncher-rb-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ self, nixpkgs, ... }:
    let
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" ];
      allSystems = linuxSystems ++ darwinSystems;
      forEachSystem = nixpkgs.lib.genAttrs allSystems;
      forEachPkgs = f: forEachSystem (system: f nixpkgs.legacyPackages.${system});
      mkHost = import ./lib/mk-host.nix { inherit inputs; };
    in
    {
      packages = forEachPkgs (pkgs: import ./pkgs { inherit pkgs; });
      devShells = forEachPkgs (pkgs: import ./shell.nix { inherit pkgs; });
      formatter = forEachPkgs (pkgs: pkgs.nixpkgs-fmt);

      nixosConfigurations = {
        rabanastre = mkHost.nixos {
          hostName = "rabanastre";
          system = "x86_64-linux";
          hostModule = ./hosts/rabanastre;
          homeModule = ./home/dawei/rabanastre.nix;
          extraModules = [
            inputs.nixos-hardware.nixosModules.microsoft-surface-pro-intel
          ];
        };

        valendia = mkHost.nixos {
          hostName = "valendia";
          system = "x86_64-linux";
          hostModule = ./hosts/valendia;
          homeModule = ./home/dawei/valendia.nix;
          extraModules = [
            inputs.aagl.nixosModules.default
            ({ pkgs, ... }: {
              nix.settings = inputs.aagl.nixConfig;
              programs.sleepy-launcher = {
                enable = true;
                package = inputs.aagl.packages.${pkgs.stdenv.hostPlatform.system}.sleepy-launcher;
              };
            })
          ];
        };
      };

      darwinConfigurations = {
        LT-US24-MAC-137 = mkHost.darwin {
          hostName = "LT-US24-MAC-137";
          system = "aarch64-darwin";
          hostModule = ./hosts/darwin;
          homeUser = "david.huynh";
          homeModule = ./home/dawei/darwin.nix;
          extraModules = [
            {
              nixpkgs.overlays = [
                inputs.nixpkgs-firefox-darwin.overlay
              ];
            }
          ];
        };
      };
    };
}
