{ lib, pkgs, ... }:

let
  primaryUser = "david.huynh";
  bashLoginShell = "/run/current-system/sw${pkgs.bashInteractive.shellPath}";
in
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

  programs = {
    bash.enable = true;
    zsh.enable = true;
  };

  environment.variables = {
    EDITOR = "vim";
    MOZ_LEGACY_PROFILES = "1";
  };

  users.users.${primaryUser} = {
    name = primaryUser;
    home = "/Users/${primaryUser}";
    shell = pkgs.bashInteractive;
  };

  system.primaryUser = primaryUser;

  system.activationScripts.setPrimaryUserShell.text = ''
    current_shell=$(/usr/bin/dscl . -read /Users/${primaryUser} UserShell 2>/dev/null | /usr/bin/awk '{ print $2 }' || true)
    if [ "$current_shell" != "${bashLoginShell}" ]; then
      echo "setting ${primaryUser} login shell to ${bashLoginShell}..." >&2
      /usr/bin/dscl . -create /Users/${primaryUser} UserShell "${bashLoginShell}"
    fi
  '';

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
