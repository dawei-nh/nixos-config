{ lib, config, pkgs, ... }:

{
  options.my.features.discord.enable = lib.mkEnableOption "Discord clients";

  config = lib.mkIf config.my.features.discord.enable {
    home.packages = with pkgs; [
      discord
      vesktop
      webcord
    ];
  };
}
