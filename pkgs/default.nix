{ pkgs, ... }:

{
  omp-bin = pkgs.callPackage ./omp-bin.nix { };
} // pkgs.lib.optionalAttrs (pkgs.stdenv.hostPlatform.system == "x86_64-linux") {
  snapmaker-orca = pkgs.callPackage ./snapmaker-orca.nix { };
}
