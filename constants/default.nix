{pkgs, ...}: {
  hosts = import ./hosts.nix;
  mime-types = pkgs.callPackage ./mime-types.nix {};
  packages = pkgs.callPackage ./packages.nix {};
  registry = import ./registry.nix;
}
