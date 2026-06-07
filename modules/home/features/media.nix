{ lib, config, pkgs, ... }:

{
  options.my.features.media.enable = lib.mkEnableOption "media tools";

  config = lib.mkIf config.my.features.media.enable {
    home.packages = with pkgs; [ mpv ];
  };
}
