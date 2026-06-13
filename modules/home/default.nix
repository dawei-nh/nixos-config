{
  imports = [
    ./user.nix
    ./package-tiers.nix
    ./features/discord.nix
    ./features/firefox.nix
    ./features/git.nix
    ./features/ghostty.nix
    ./features/media.nix
    ./features/plasma.nix
    ./features/omp.nix
    ./features/shell.nix
    ./features/sketchybar.nix
    ./features/vscode.nix
    ./features/zen.nix
    # TODO: Import Linux-only profiles from Linux home configs instead of this
    # shared module root, so Linux-only feature implementations do not need to
    # be split from their option declarations.
    ./profiles/linux-desktop.nix
  ];
}
