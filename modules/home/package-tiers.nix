{ lib, config, pkgs, ... }:

let
  cfg = config.my.home;

  tierPackages = {
    core = with pkgs; [
      hyfetch
      nnn
      zip
      xz
      unzip
      p7zip
      ripgrep
      jq
      yq-go
      eza
      fzf
      mtr
      iperf3
      dnsutils
      ldns
      socat
      nmap
      ipcalc
      file
      which
      tree
      gnused
      gnutar
      gawk
      zstd
      gnupg
      nix-output-monitor
      btop
      iftop
      lsof
      vim
      dejavu_fonts
      powerline-fonts
      font-awesome
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
      eza
      git
      htop
      python3
      screen
      wget
      vim
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
    default = [ "core" ];
  };

  config.home.packages = lib.concatLists (map (tier: tierPackages.${tier}) cfg.packageTiers);
}
