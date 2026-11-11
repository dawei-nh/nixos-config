{ lib, config, pkgs, ... }:

{
  options.my.nixos.sidestore.enable = lib.mkEnableOption "SideStore installation and IPA loading with iLoader";

  config = lib.mkIf config.my.nixos.sidestore.enable {
    services.usbmuxd.enable = true;

    environment.systemPackages = with pkgs; [
      (iloader.overrideAttrs (old: {
        # Nixpkgs configures aws-lc-sys to use the system library.
        buildInputs = old.buildInputs ++ [ aws-lc ];
      }))
      libimobiledevice
    ];

    # Keep USB trust and pairing records across boots on ephemeral root systems.
    environment.persistence."/persist/system" = lib.mkIf config.my.nixos.impermanence.enable {
      directories = [
        {
          directory = "/var/lib/lockdown";
          user = config.services.usbmuxd.user;
          group = config.services.usbmuxd.group;
          mode = "02775";
        }
      ];
    };
  };
}
