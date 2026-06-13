{ lib, config, pkgs, ... }:

let
  cfg = config.my.features.plasma;
in
{
  options.my.features.plasma.enable = lib.mkEnableOption "KDE Plasma top panel";

  config = lib.mkIf (cfg.enable && pkgs.stdenv.isLinux) {
    programs.plasma = {
      enable = true;
      panels = [
        {
          location = "top";
          height = 44;
          floating = true;
          hiding = "none";
          screen = "all";
        }
      ];
    };
  };
}
