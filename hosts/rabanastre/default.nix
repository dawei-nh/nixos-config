{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ../../modules/nixos
  ];

  fileSystems."/persist" = {
    device = "/dev/nvme0n1p3";
    fsType = "btrfs";
    options = [ "subvol=persist" ];
    neededForBoot = true;
  };

  nix.settings.build-dir = "/root/nix-build-tmp";

  nixpkgs.overlays = [
    (_final: prev: {
      runelite = prev.runelite.overrideAttrs (oldAttrs: {
        postFixup = (oldAttrs.postFixup or "") + ''
          wrapProgram $out/bin/runelite --set GDK_SCALE 2
        '';
      });
    })
  ];

  systemd.tmpfiles.rules = [
    "d /root/nix-build-tmp 0755 root root -"
  ];

  networking.hostName = "rabanastre";

  my.nixos = {
    impermanence.enable = true;
    profiles.linuxDesktop.enable = true;
    tailscale.enable = true;
    cachixCache = {
      enable = true;
      cacheName = "dawei-nh";
      publicKey = "dawei-nh.cachix.org-1:HExzwh8E3R1PKdbT7QP7kyxzlDPM4dvCtYnmbLGXOk0=";
    };
  };

  boot = {
    blacklistedKernelModules = [
      "ipu3_imgu"
    ];
  };

  hardware.microsoft-surface.kernelVersion = "stable";

  users.users.dawei.extraGroups = [ "surface-control" ];

  programs.partition-manager.enable = true;

  system.stateVersion = "23.05";
}
