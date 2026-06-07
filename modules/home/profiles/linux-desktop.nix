{ lib, config, ... }:

let
  cfg = config.my.home.profiles.linuxDesktop;
in
{
  options.my.home.profiles.linuxDesktop.enable = lib.mkEnableOption "shared Linux desktop Home Manager profile";

  config = lib.mkIf cfg.enable {
    my.home.packageTiers = lib.mkDefault [
      "core"
      "devops"
      "linuxDesktop"
    ];

    my.features = {
      zen = {
        enable = lib.mkDefault true;
        makeDefaultBrowser = lib.mkDefault true;
      };
      firefox.enable = lib.mkDefault true;
      vscode.enable = lib.mkDefault true;
      discord.enable = lib.mkDefault true;
      media.enable = lib.mkDefault true;
    };
  };
}
