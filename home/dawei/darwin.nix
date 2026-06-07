{ config, lib, pkgs, ... }:

{
  imports = [
    ../../modules/home
  ];

  my.home = {
    userName = "david.huynh";
    homeDirectory = "/Users/david.huynh";
    packageTiers = [
      "core"
      "mac"
    ];
  };

  my.features = {
    firefox = {
      enable = true;
      makeDefaultBrowser = true;
    };
    vscode.enable = true;
    sketchybar.enable = true;
  };

  # https://github.com/nix-community/home-manager/issues/1341
  home.activation.aliasHomeManagerApplications = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    app_folder="${config.home.homeDirectory}/Applications/Home Manager Trampolines"
    rm -rf "$app_folder"
    mkdir -p "$app_folder"
    find "$genProfilePath/home-path/Applications" -type l -print | while read -r app; do
        app_target="$app_folder/$(basename "$app")"
        real_app="$(readlink "$app")"
        echo "mkalias \"$real_app\" \"$app_target\"" >&2
        $DRY_RUN_CMD ${pkgs.mkalias}/bin/mkalias "$real_app" "$app_target"
    done
  '';

  home.sessionVariables = {
    EDITOR = "vim";
    MOZ_LEGACY_PROFILES = "1";
  };

  home.stateVersion = "24.05";
}
