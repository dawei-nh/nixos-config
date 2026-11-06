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
    # The Surface 6.19.8 kernel predates Rust 1.98's softfloat ABI rename.
    # Remove this backport once nixos-hardware includes the upstream fix.
    kernelPatches = [
      {
        name = "rust-x86-support-rust-1.98-target-spec";
        patch = pkgs.fetchurl {
          url = "https://github.com/torvalds/linux/commit/905b06d32a52afe32fcf5f30cf298c9ea6359f11.patch";
          hash = "sha256-HoCjPlgF7ZxY0W4a4dfyUmpJMHF+p5US1gLKKPUgjhM=";
        };
      }
    ];
    blacklistedKernelModules = [
      "ipu3_imgu"
    ];
  };

  hardware.microsoft-surface.kernelVersion = "stable";

  users.users.dawei.extraGroups = [ "surface-control" ];

  programs.partition-manager.enable = true;

  system.stateVersion = "23.05";
}
