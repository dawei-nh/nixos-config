{ lib, config, ... }:

{
  options.my.nixos.pipewire.enable = lib.mkEnableOption "PipeWire";

  config = lib.mkIf config.my.nixos.pipewire.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };
    security.rtkit.enable = true;
  };
}
