{ lib, config, ... }:

let
  cfg = config.my.nixos.impermanence;

  persistedDirectories = [
    "/var/lib/flatpak"
    { directory = "/var/lib/tailscale"; mode = "0700"; }
    { directory = "/var/lib/docker"; mode = "0710"; }
    "/var/lib/nixos"
    "/var/lib/NetworkManager"
    "/var/lib/bluetooth"
    "/var/lib/systemd/backlight"
    "/var/lib/systemd/rfkill"
    { directory = "/var/lib/AccountsService"; mode = "0775"; }
    "/var/lib/fwupd"
    { directory = "/var/lib/sddm"; mode = "0700"; }
    { directory = "/var/tmp"; mode = "1777"; }
  ];
in
{
  options.my.nixos.impermanence.enable = lib.mkEnableOption "impermanence persistence";

  config = lib.mkIf cfg.enable {
    environment.persistence."/persist/system" = {
      hideMounts = true;
      directories = persistedDirectories;
    };
  };
}
