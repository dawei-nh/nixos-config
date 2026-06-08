{ lib, pkgs, ... }:

let
  xb270_edid = pkgs.runCommand "xb270_edid" { compressFirmware = false; } ''
    mkdir -p $out/lib/firmware/edid
    cp ${./xb270hu.bin} $out/lib/firmware/edid/xb270hu.bin
  '';
in
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  fileSystems."/persist" = {
    device = "/dev/disk/by-uuid/f3aa695b-9f31-4673-bc6f-04110984ba54";
    fsType = "btrfs";
    options = [ "subvol=persist" ];
    neededForBoot = true;
  };

  networking.hostName = "valendia";

  my.nixos = {
    impermanence.enable = true;
    profiles.linuxDesktop.enable = true;
    sunshine.enable = true;
    steam.enable = true;
  };

  boot.kernelPackages = pkgs.linuxKernel.packages.linux_zen;

  hardware.firmware = [ xb270_edid ];

  services.xserver.videoDrivers = [ "amdgpu" ];

  services.sunshine = {
    settings.output_name = 1;
    applications = {
      env.PATH = "$(PATH):$(HOME)/.local/bin";
      apps = [
        {
          name = "Steam Big Picture";
          output = "/var/log/sunshine.log";
          prep-cmd = [
            {
              do = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-1.mode.1920x1080@60";
              undo = "${pkgs.kdePackages.libkscreen}/bin/kscreen-doctor output.DP-1.mode.3440x1440@144";
            }
          ];
          exclude-global-prep-cmd = "false";
          auto-detach = "true";
          image-path = "steam.png";
          detached = [ "${pkgs.util-linux}/bin/setsid ${pkgs.steam}/bin/steam steam://open/bigpicture" ];
        }
      ];
    };
  };

  environment.systemPackages = with pkgs; lib.optional (kdePackages ? xwaylandvideobridge) kdePackages.xwaylandvideobridge ++ [
    gamescope
    mangohud
  ];

  services.udev.packages = with pkgs; [
    ledger-udev-rules
  ];

  system.stateVersion = "24.05";
}
