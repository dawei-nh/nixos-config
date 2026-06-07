{ inputs, lib, config, pkgs, ... }:

let
  cfg = config.my.features.firefox;
in
{
  options.my.features.firefox = {
    enable = lib.mkEnableOption "Firefox fallback browser";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.firefox-bin or pkgs.firefox;
    };

    makeDefaultBrowser = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = lib.mkIf pkgs.stdenv.isDarwin [ cfg.package ];
    }

    (lib.mkIf pkgs.stdenv.isLinux {
      programs.firefox = {
        enable = true;
        package = cfg.package;
        configPath = ".mozilla/firefox";
        policies = {
          DefaultDownloadDirectory = "\${home}/Downloads";
          DisablePocket = true;
          DisableTelemetry = true;
          DNSOverHTTPS = {
            Enabled = true;
            ExcludedDomains = [ "dawei.dev" ];
          };
          OfferToSaveLogins = false;
          PasswordManagerEnabled = false;
        };
        profiles.dawei = {
          bookmarks = { };
          extensions.packages = with inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system}; [
            ublock-origin
            bitwarden
            tree-style-tab
          ];
          settings = {
            "browser.disableResetPrompt" = true;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.shell.checkDefaultBrowser" = false;
            "browser.shell.defaultBrowserCheckCount" = 1;
            "signon.rememberSignons" = false;
            "pref.privacy.disable_button.view_passwords" = true;
            "browser.startup.homepage" = "https://start.duckduckgo.com";
            "browser.startup.page" = 3;
            "dom.security.https_only_mode" = true;
            "dom.security.https_only_mode_ever_enabled" = true;
            "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
            "extensions.pocket.enabled" = false;
            "extensions.pocket.api" = "";
            "extensions.pocket.oAuthConsumerKey" = "";
            "extensions.pocket.showHome" = false;
            "extensions.pocket.site" = "";
            "privacy.donottrackheader.enabled" = true;
            "privacy.trackingprotection.enabled" = true;
            "privacy.trackingprotection.socialtracking.enabled" = true;
            "privacy.partition.network_state.ocsp_cache" = true;
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;
            "browser.ping-centre.telemetry" = false;
            "datareporting.healthreport.uploadEnabled" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;
            "toolkit.telemetry.archive.enabled" = false;
            "toolkit.telemetry.bhrPing.enabled" = false;
            "toolkit.telemetry.enabled" = false;
            "toolkit.telemetry.firstShutdownPing.enabled" = false;
            "toolkit.telemetry.hybridContent.enabled" = false;
            "toolkit.telemetry.newProfilePing.enabled" = false;
            "toolkit.telemetry.reportingpolicy.firstRun" = false;
            "toolkit.telemetry.shutdownPingSender.enabled" = false;
            "toolkit.telemetry.unified" = false;
            "toolkit.telemetry.updatePing.enabled" = false;
            "experiments.activeExperiment" = false;
            "experiments.enabled" = false;
            "experiments.supported" = false;
            "network.allow-experiments" = false;
            "network.trr.mode" = 3;
            "network.trr.excluded-domains" = "dawei.dev,*.dawei.dev,azure.net";
          };
        };
      };

      xdg.mimeApps.defaultApplications = lib.mkIf cfg.makeDefaultBrowser {
        "text/html" = [ "firefox.desktop" ];
        "text/xml" = [ "firefox.desktop" ];
        "x-scheme-handler/http" = [ "firefox.desktop" ];
        "x-scheme-handler/https" = [ "firefox.desktop" ];
      };
    })
  ]);
}
