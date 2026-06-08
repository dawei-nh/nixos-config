{
  imports = [
    ../../modules/darwin
  ];

  networking.hostName = "LT-US24-MAC-137";

  ids.gids.nixbld = 30000;

  my.darwin = {
    sketchybar.enable = true;
  };

  system.stateVersion = 5;
}
