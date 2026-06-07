{ inputs, ... }:

{
  imports = [
    inputs.impermanence.nixosModules.impermanence
    ./base.nix
    ./cachix-cache.nix
    ./desktop-plasma.nix
    ./fstrim.nix
    ./impermanence.nix
    ./nautilus.nix
    ./pipewire.nix
    ./profiles/linux-desktop.nix
    ./steam.nix
    ./sunshine.nix
    ./tailscale.nix
  ];
}
