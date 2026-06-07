{ lib, config, ... }:

{
  options.my.nixos.tailscale.enable = lib.mkEnableOption "Tailscale";

  config = lib.mkIf config.my.nixos.tailscale.enable {
    services.tailscale.enable = true;
  };
}
