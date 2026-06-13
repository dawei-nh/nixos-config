{ inputs, ... }:

{
  imports = [
    inputs.omp-nix.homeManagerModules.default
  ];

  oh-my-pi = {
    enable = true;
    settings = {
      symbolPreset = "nerd";
      theme.dark = "dark-tokyo-night";
      modelRoles.default = "openai-codex/gpt-5.5:high";
      hideThinkingBlock = false;
    };
  };
}
