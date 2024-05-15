{
  description = "A NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
  }: {
    nixosConfigurations.mawz-fw = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./hosts/mawz-fw/configuration.nix
        nixos-hardware.nixosModules.framework-11th-gen-intel
      ];
    };
    nixosConfigurations.mawz-nuc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [./hosts/mawz-nuc/configuration.nix];
    };
  };
}
