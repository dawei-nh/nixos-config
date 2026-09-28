{ inputs, ... }:

{
  imports = [
    inputs.omp.homeManagerModules.default
  ];

  programs.omp = {
    enable = true;
    settings = {
      symbolPreset = "nerd";
      theme.dark = "dark-tokyo-night";
      modelRoles.default = "openai-codex/gpt-5.5:high";
      hideThinkingBlock = false;
      setupVersion = 1;
    };
  };
}
