{ inputs, pkgs, ... }:

{
  imports = [
    inputs.omp.homeManagerModules.default
  ];

  programs.omp = {
    enable = true;
    # Repackage upstream release binaries instead of compiling Rust and Bun.
    package = pkgs.callPackage ../../../pkgs/omp-bin.nix { };
    settings = {
      symbolPreset = "nerd";
      theme.dark = "dark-tokyo-night";
      modelRoles.default = "openai-codex/gpt-5.5:high";
      hideThinkingBlock = false;
      setupVersion = 1;
    };
  };
}
