{
  description = "A NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  } @ attrs: {
    nixosConfigurations.mawz-fw = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = attrs;
      modules = [
        ./hosts/mawz-fw/configuration.nix
        attrs.nixos-hardware.nixosModules.framework-11th-gen-intel
      ];
    };
    nixosConfigurations.mawz-nuc = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [./hosts/mawz-nuc/configuration.nix];
    };
  };
}
