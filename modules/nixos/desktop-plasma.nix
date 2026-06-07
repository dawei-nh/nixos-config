{ lib, config, pkgs, ... }:

let
  cfg = config.my.nixos.desktop.plasma;
in
{
  options.my.nixos.desktop.plasma.enable = lib.mkEnableOption "Plasma desktop";

  config = lib.mkIf cfg.enable {
    services.xserver.enable = true;
    services.desktopManager.plasma6.enable = true;
    services.displayManager.sddm = {
      enable = true;
      wayland.enable = true;
      theme = "where_is_my_sddm_theme";
    };
    services.gnome.gnome-keyring.enable = true;
    security.pam.services.sddm.enableGnomeKeyring = true;
    services.xserver.xkb.layout = "us";
    services.libinput.enable = true;
    programs.xwayland.enable = true;
    xdg.portal = {
      enable = true;
      xdgOpenUsePortal = true;
      wlr.enable = false;
    };
    environment.systemPackages = with pkgs; [
      where-is-my-sddm-theme
      adwaita-icon-theme
    ];
  };
}
