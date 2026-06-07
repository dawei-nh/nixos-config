{ lib, config, ... }:

{
  options.my.nixos.fstrim.enable = lib.mkEnableOption "periodic fstrim";

  config = lib.mkIf config.my.nixos.fstrim.enable {
    services.fstrim.enable = true;
  };
}
