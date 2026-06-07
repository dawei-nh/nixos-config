{ lib, config, ... }:

let
  cfg = config.my.nixos.profiles.linuxDesktop;
in
{
  options.my.nixos.profiles.linuxDesktop.enable = lib.mkEnableOption "shared Linux desktop profile";

  config = lib.mkIf cfg.enable {
    networking.networkmanager.enable = true;

    my.nixos = {
      desktop.plasma.enable = true;
      steam.enable = true;
      pipewire.enable = true;
      fstrim.enable = true;
      nautilus.enable = true;
    };

    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
        timeout = 0;
      };
      plymouth = {
        enable = true;
        theme = "breeze";
      };
      kernelParams = [
        "quiet"
        "loglevel=3"
        "systemd.show_status=auto"
        "udev.log_level=3"
        "rd.udev.log_level=3"
        "vt.global_cursor_default=0"
      ];
      consoleLogLevel = 0;
      initrd.verbose = false;
    };

    console = {
      useXkbConfig = true;
      earlySetup = false;
    };

    # Plasma enables fwupd. Keep firmware update support available, but do not let
    # metadata refresh failures block NixOS rebuild switches.
    systemd.timers.fwupd-refresh.enable = false;
  };
}
