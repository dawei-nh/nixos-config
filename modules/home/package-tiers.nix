{ lib, config, pkgs, ... }:

let
  cfg = config.my.home;

  basePackageTiers = [
    "core"
    "archives"
    "cli"
    "networking"
    "unix"
    "fonts"
    "dev"
  ];

  tierPackages = {
    core = with pkgs; [
      hyfetch
      nnn
      file
      which
      tree
      vim
    ];

    archives = with pkgs; [
      zip
      xz
      unzip
      p7zip
      zstd
    ];

    cli = with pkgs; [
      ripgrep
      jq
      yq-go
      eza
      fzf
      gnupg
      nix-output-monitor
      btop
      lsof
    ];

    networking = with pkgs; [
      mtr
      iperf3
      dnsutils
      ldns
      socat
      nmap
      ipcalc
      iftop
    ];

    unix = with pkgs; [
      gnused
      gnutar
      gawk
    ];

    fonts = with pkgs; [
      dejavu_fonts
      powerline-fonts
      font-awesome
    ];

    dev = with pkgs; [
      pre-commit
    ];

    devops = with pkgs; [
      kubectl
      kubelogin
      kubernetes-helm
      k9s
      azure-functions-core-tools
      awscli2
      checkov
      tfswitch
      terraform
      terraform-docs
      tflint
    ];

    linuxDesktop = with pkgs; [
      iotop
      strace
      ltrace
      sysstat
      lm_sensors
      ethtool
      pciutils
      usbutils
      cura-appimage
      orca-slicer
    ];

    gaming = with pkgs; [
      gamemode
      lutris
      protonup-qt
      umu-launcher
      wowup-cf
    ];

    mac = with pkgs; [
      bat
      git
      htop
      python3
      screen
      wget
      colima
      docker
    ];

    crypto = with pkgs; [
      ledger-live-desktop
    ];
  };
in
{
  options.my.home.packageTiers = lib.mkOption {
    type = lib.types.listOf (lib.types.enum (builtins.attrNames tierPackages));
    default = basePackageTiers;
  };

  config.home.packages = lib.unique (lib.concatLists (map (tier: tierPackages.${tier}) cfg.packageTiers));
}
