{ lib, config, pkgs, ... }:

let
  cfg = config.my.features.ghostty;
  keyValueSettings = {
    listsAsDuplicateKeys = true;
    mkKeyValue = lib.generators.mkKeyValueDefault { } " = ";
  };
  keyValue = pkgs.formats.keyValue keyValueSettings;
  defaultPackage =
    if pkgs.stdenv.hostPlatform.isDarwin then
      pkgs.ghostty-bin
    else
      pkgs.ghostty;
in
{
  options.my.features.ghostty = {
    enable = lib.mkEnableOption "Ghostty terminal" // {
      default = true;
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = defaultPackage;
      description = "Ghostty package to install. Defaults to ghostty-bin on Darwin and ghostty elsewhere.";
    };

    settings = lib.mkOption {
      inherit (keyValue) type;
      default = {
        theme = "Solarized Osaka Night";
        font-size = 12;
        font-thicken = true;
        adjust-cell-height = "5%";
      };
      description = "Ghostty settings written to the generated config file.";
    };

    themes = lib.mkOption {
      type = lib.types.attrsOf keyValue.type;
      default = { };
      description = "Custom Ghostty themes written under the generated themes directory.";
    };

    clearDefaultKeybinds = lib.mkEnableOption "clearing Ghostty's default keybindings";
  };

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      package = cfg.package;
      inherit (cfg) clearDefaultKeybinds settings themes;
    };
  };
}
