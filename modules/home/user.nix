{ lib, config, ... }:

let
  cfg = config.my.home;
in
{
  options.my.home = {
    userName = lib.mkOption {
      type = lib.types.str;
      default = "dawei";
    };

    homeDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/home/${cfg.userName}";
    };
  };

  config = {
    home.username = cfg.userName;
    home.homeDirectory = cfg.homeDirectory;
    fonts.fontconfig.enable = lib.mkDefault true;
    programs.home-manager.enable = lib.mkDefault true;
  };
}
