{ lib, config, inputs, pkgs, ... }:

let
  cfg = config.my.features.zen;
  zenPackages = inputs.zen-browser.packages or { };
  upstreamPackage = zenPackages.${pkgs.stdenv.hostPlatform.system}.default or null;
  # The upstream flake still sets ffmpegSupport; nixpkgs now reads withFFmpeg.
  defaultPackage =
    if upstreamPackage == null then null else
    pkgs.wrapFirefox
      (upstreamPackage.unwrapped.overrideAttrs (old: {
        passthru = old.passthru // { withFFmpeg = true; };
      }))
      {
        pname = "zen-browser";
      };
  desktopFile = "zen.desktop";
in
{
  options.my.features.zen = {
    enable = lib.mkEnableOption "Zen Browser";

    package = lib.mkOption {
      type = lib.types.nullOr lib.types.package;
      default = defaultPackage;
      description = "Zen Browser package to install. Defaults to the selected flake package when available.";
    };

    makeDefaultBrowser = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf (cfg.enable && cfg.package != null) {
    home.packages = [ cfg.package ];

    xdg.mimeApps.defaultApplications = lib.mkIf cfg.makeDefaultBrowser {
      "text/html" = [ desktopFile ];
      "text/xml" = [ desktopFile ];
      "x-scheme-handler/http" = [ desktopFile ];
      "x-scheme-handler/https" = [ desktopFile ];
    };
  };
}
