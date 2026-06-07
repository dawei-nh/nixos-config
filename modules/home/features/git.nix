{ lib, config, ... }:

{
  options.my.features.git.enable = lib.mkEnableOption "Git configuration" // {
    default = true;
  };

  config = lib.mkIf config.my.features.git.enable {
    programs.git = {
      enable = true;
      settings = {
        user.name = "David Huynh";
        user.email = "davidnhuynh@gmail.com";
      };
    };
  };
}
