{ pkgs, ... }:

{
  omp-bin = pkgs.callPackage ./omp-bin.nix { };
}
