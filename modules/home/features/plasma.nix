{ lib, ... }:

{
  options.my.features.plasma.enable = lib.mkEnableOption "KDE Plasma top panel";
}
