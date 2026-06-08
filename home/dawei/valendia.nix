{
  imports = [
    ../../modules/home
  ];

  my.home = {
    userName = "dawei";
    homeDirectory = "/home/dawei";
    profiles.linuxDesktop.enable = true;
    packageTiers = [
      "core"
      "archives"
      "cli"
      "networking"
      "unix"
      "fonts"
      "dev"
      "devops"
      "linuxDesktop"
      "gaming"
      "crypto"
    ];
  };

  home.stateVersion = "24.05";
}
