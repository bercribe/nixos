{
  description = "A NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    stylix.url = "github:danth/stylix?ref=release-24.05";
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    sops-nix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
  in {
    nixosConfigurations.mawz-hue = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules = [
        ./modules/overlays.nix
        ./hosts/mawz-hue/configuration.nix
        sops-nix.nixosModules.sops
      ];
    };
    nixosConfigurations.mawz-fw = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules = [
        ./modules/overlays.nix
        ./hosts/mawz-fw/configuration.nix
        nixos-hardware.nixosModules.framework-11th-gen-intel
        sops-nix.nixosModules.sops
      ];
    };
    nixosConfigurations.mawz-nuc = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules = [
        sops-nix.nixosModules.sops
        ./hosts/mawz-nuc/configuration.nix
      ];
    };
  };
}
