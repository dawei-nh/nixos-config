{
  imports = [
    ../../modules/darwin
  ];

  networking.hostName = "LT-US26-MAC-200";

  my.darwin = {
    sketchybar.enable = true;
  };

  system.stateVersion = 5;
}
