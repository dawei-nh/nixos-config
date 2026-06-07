{ lib, ... }:

{
  nix = {
    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 0;
        Minute = 0;
      };
      options = "--delete-older-than 7d";
    };
    optimise.automatic = true;
    settings.experimental-features = [
      "nix-command"
      "flakes"
    ];
  };

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-darwin";

  programs.zsh.enable = true;

  environment.variables = {
    EDITOR = "vim";
    MOZ_LEGACY_PROFILES = "1";
  };

  users.users."david.huynh" = {
    name = "david.huynh";
    home = "/Users/david.huynh";
  };

  system.primaryUser = "david.huynh";

  system.defaults.NSGlobalDomain = {
    AppleShowAllExtensions = true;
    AppleKeyboardUIMode = 3;
    ApplePressAndHoldEnabled = false;
    NSNavPanelExpandedStateForSaveMode = true;
    NSNavPanelExpandedStateForSaveMode2 = true;
    PMPrintingExpandedStateForPrint = true;
    PMPrintingExpandedStateForPrint2 = true;
    _HIHideMenuBar = true;
  };
  system.defaults.menuExtraClock = {
    Show24Hour = true;
    ShowDate = 0;
  };
  system.defaults.dock = {
    autohide = true;
    orientation = "right";
    wvous-br-corner = 4;
  };
  system.defaults.finder = {
    FXPreferredViewStyle = "Nlsv";
    ShowPathbar = true;
    ShowStatusBar = true;
  };
  system.defaults.spaces.spans-displays = false;
}
