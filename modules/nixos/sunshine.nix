{ lib, config, ... }:

{
  options.my.nixos.sunshine.enable = lib.mkEnableOption "Sunshine";

  config = lib.mkIf config.my.nixos.sunshine.enable {
    services.sunshine = {
      enable = true;
      autoStart = true;
      capSysAdmin = true;
      openFirewall = true;
    };
  };
}
