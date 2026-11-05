{ inputs, lib, config, pkgs, ... }:

let
  cfg = config.my.home;
  xivlauncher-rb = inputs.xivlauncher-rb.packages.${pkgs.stdenv.hostPlatform.system}.xivlauncher-rb or null;
  # Keep the prebuilt native Codex CLI available as a fallback to omp.
  codex = inputs.codex-cli-nix.packages.${pkgs.stdenv.hostPlatform.system}.codex;

  # Fabric used by Azure CLI does not support Invoke 3 yet.
  # Scope the compatible Invoke version to Azure CLI and its extensions.
  azureCli = (pkgs.extend (_final: prev: {
    pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
      (_pythonFinal: pythonPrev: {
        invoke = pythonPrev.invoke.overridePythonAttrs (_old: rec {
          version = "2.2.1";
          src = pkgs.fetchPypi {
            pname = "invoke";
            inherit version;
            hash = "sha256-UVv0m0pIkyt5sCRZA0jaIvOcSULf+ZGtH7i4uuob5wc=";
          };
        });
      })
    ];
  })).azure-cli;

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
      gh
      codex
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
      nerd-fonts.jetbrains-mono
      nerd-fonts.fira-code
    ];

    dev = with pkgs; [
      pre-commit
    ];

    devops = with pkgs; [
      kubectl
      kubelogin
      kubernetes-helm
      k9s
      (azureCli.withExtensions [
        azureCli.extensions.aks-preview
        azureCli.extensions.azure-devops
        azureCli.extensions.fleet
        azureCli.extensions.quota
        azureCli.extensions.terraform
      ])
      azure-functions-core-tools
      awscli2
      # checkov
      tfswitch
      terraform
      terragrunt
      terraform-docs
      tflint
      opentofu
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
      runelite
      bolt-launcher
    ];

    gaming = with pkgs; [
      gamemode
      lutris
      protonup-qt
      umu-launcher
      wowup-cf
    ] ++ lib.optional (xivlauncher-rb != null) xivlauncher-rb;

    mac = with pkgs; [
      bat
      git
      htop
      python3
      nodejs
      screen
      wget
      claude-code
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
