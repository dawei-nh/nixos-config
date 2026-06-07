{ lib, config, ... }:

{
  options.my.features.sketchybar.enable = lib.mkEnableOption "SketchyBar Home Manager files";

  config = lib.mkIf config.my.features.sketchybar.enable {
    home.file.".config/sketchybar" = {
      source = ../../darwin/sketchybar/config;
      recursive = true;
    };
  };
}
