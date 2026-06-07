{ lib, config, pkgs, ... }:

{
  options.my.nixos.nautilus.enable = lib.mkEnableOption "Nautilus";

  config = lib.mkIf config.my.nixos.nautilus.enable {
    environment.systemPackages = with pkgs; [ nautilus ];
    programs.nautilus-open-any-terminal = {
      enable = true;
      terminal = "alacritty";
    };
  };
}
