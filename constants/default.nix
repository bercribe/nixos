{pkgs, ...}: {
  hosts = import ./hosts.nix;
  mime-types = pkgs.callPackage ./mime-types.nix {};
  registry = import ./registry.nix;
}
