{ lib, config, ... }:

let
  cfg = config.my.features.plasma;
in
{
  config = lib.mkIf cfg.enable {
    programs.plasma = {
      enable = true;
      panels = [
        {
          location = "top";
          height = 44;
          floating = true;
          hiding = "none";
          screen = "all";
        }
      ];
    };
  };
}
