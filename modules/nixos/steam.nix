{
  lib,
  config,
  pkgs,
  ...
}:

{
  options.my.nixos.steam.enable = lib.mkEnableOption "Steam";

  config = lib.mkIf config.my.nixos.steam.enable {
    programs.gamemode.enable = true;
    programs.steam = {
      enable = true;
      package = pkgs.steam.override {
        extraArgs = "-pipewire";
      };
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
    };
    users.users.dawei.extraGroups = [ "gamemode" ];
  };
}
