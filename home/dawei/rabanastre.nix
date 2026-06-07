{
  imports = [
    ../../modules/home
  ];

  my.home = {
    userName = "dawei";
    homeDirectory = "/home/dawei";
    profiles.linuxDesktop.enable = true;
  };

  home.stateVersion = "23.05";
}
