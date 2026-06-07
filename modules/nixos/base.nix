{ lib, ... }:

{
  nix = {
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  nixpkgs.config.allowUnfree = true;

  environment.enableAllTerminfo = true;
  hardware.enableRedistributableFirmware = true;
  networking.domain = lib.mkDefault "ivalice.local";

  i18n = {
    defaultLocale = lib.mkDefault "en_US.UTF-8";
    supportedLocales = lib.mkDefault [ "en_US.UTF-8/UTF-8" ];
  };
  time.timeZone = lib.mkDefault "America/Chicago";

  users.users.dawei = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
  };

  environment.variables.EDITOR = "vim";
}
