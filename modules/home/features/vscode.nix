{ inputs, lib, config, pkgs, ... }:

{
  options.my.features.vscode.enable = lib.mkEnableOption "VS Code";

  config = lib.mkIf config.my.features.vscode.enable {
    programs.vscode = {
      enable = true;
      package = pkgs.vscode;
      profiles.default = {
        enableUpdateCheck = false;
        enableExtensionUpdateCheck = false;

        extensions = with inputs.nix-vscode-extensions.extensions.${pkgs.stdenv.hostPlatform.system}.vscode-marketplace; [
          editorconfig.editorconfig
          vscodevim.vim
          zhuangtongfa.material-theme
          jnoortheen.nix-ide
          arrterian.nix-env-selector
        ];

        userSettings = {
          "window.titleBarStyle" = "custom";
          "workbench.colorTheme" = "One Dark Pro Flat";
          "editor.fontFamily" = "'FiraCode Nerd Font', 'FiraCode Nerd Font Mono', 'monospace', monospace";
          "editor.inlineSuggest.enabled" = true;
          "git.autofetch" = true;
          "git.confirmSync" = false;
          "[nix]"."editor.defaultFormatter" = "jnoortheen.nix-ide";
        };
      };
    };
  };
}
