{ lib, config, ... }:

{
  options.my.features.shell.enable = lib.mkEnableOption "shell configuration" // {
    default = true;
  };

  config = lib.mkIf config.my.features.shell.enable {
    programs.starship = {
      enable = true;
      settings = {
        add_newline = false;
        aws.disabled = true;
        gcloud.disabled = true;
        line_break.disabled = true;
      };
    };

    programs.alacritty = {
      enable = true;
      settings = {
        env.TERM = "xterm-256color";
        font.size = 12;
        colors.draw_bold_text_with_bright_colors = true;
        scrolling.multiplier = 5;
        selection.save_to_clipboard = true;
      };
    };

    programs.bash = {
      enable = true;
      enableCompletion = true;
      bashrcExtra = ''
        export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/go/bin"
      '';
      shellAliases = {
        k = "kubectl";
        urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
        urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
      };
    };
  };
}
