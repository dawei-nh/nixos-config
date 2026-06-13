{ inputs }:

let
  inherit (inputs.nixpkgs) lib;
in
{
  nixos =
    { hostName
    , system
    , hostModule
    , homeModule
    , homeUser ? "dawei"
    , extraModules ? [ ]
    , extraHomeSpecialArgs ? { }
    }:
    lib.nixosSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
      };
      modules =
        extraModules
        ++ [
          hostModule
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager.backupFileExtension = "backup";
          }
          {
            networking.hostName = lib.mkDefault hostName;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; } // extraHomeSpecialArgs;
            home-manager.users.${homeUser}.imports = [
              inputs.plasma-manager.homeModules.plasma-manager
              ../modules/home/features/plasma-panel.nix
              homeModule
            ];
          }
        ];
    };

  darwin =
    { hostName
    , system
    , hostModule
    , homeModule
    , homeUser
    , extraModules ? [ ]
    , extraHomeSpecialArgs ? { }
    }:
    inputs.darwin.lib.darwinSystem {
      inherit system;
      specialArgs = {
        inherit inputs;
      };
      modules =
        extraModules
        ++ [
          hostModule
          inputs.home-manager.darwinModules.home-manager
          {
            networking.hostName = lib.mkDefault hostName;
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; } // extraHomeSpecialArgs;
            home-manager.users.${homeUser}.imports = [
              homeModule
            ];
          }
        ];
    };
}
