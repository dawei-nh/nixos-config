{ lib, config, ... }:

{
  options.my.nixos.steam.enable = lib.mkEnableOption "Steam";

  config = lib.mkIf config.my.nixos.steam.enable {
    programs.gamemode.enable = true;
    programs.steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
    };
  };
}
