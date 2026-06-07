{ lib, config, ... }:

let
  cfg = config.my.nixos.cachixCache;
in
{
  options.my.nixos.cachixCache = {
    enable = lib.mkEnableOption "Cachix binary cache";

    cacheName = lib.mkOption {
      type = lib.types.str;
      example = "dawei-nixos";
      description = "Cachix cache name, without the .cachix.org suffix.";
    };

    publicKey = lib.mkOption {
      type = lib.types.str;
      example = "dawei-nixos.cachix.org-1:AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
      description = "Cachix public signing key from the cache setup page or cachix use output.";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      extra-substituters = [ "https://${cfg.cacheName}.cachix.org" ];
      extra-trusted-public-keys = [ cfg.publicKey ];
    };
  };
}
