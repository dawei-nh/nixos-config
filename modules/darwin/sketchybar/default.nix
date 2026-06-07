{ lib, config, pkgs, ... }:

{
  options.my.darwin.sketchybar.enable = lib.mkEnableOption "SketchyBar service";

  config = lib.mkIf config.my.darwin.sketchybar.enable {
    services.sketchybar = {
      enable = true;
      package = pkgs.sketchybar;
    };
  };
}
