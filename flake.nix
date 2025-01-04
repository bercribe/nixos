{
  description = "A NixOS configuration flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    home-manager = {
      url = "github:nix-community/home-manager?ref=release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";

    stylix.url = "github:danth/stylix?ref=release-24.11";
  };

  outputs = {
    self,
    nixpkgs,
    sops-nix,
    home-manager,
    stylix,
    nixos-hardware,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    commonModules = [
      sops-nix.nixosModules.sops
      home-manager.nixosModules.home-manager
    ];
    desktopModules = [
      stylix.nixosModules.stylix
    ];
  in {
    nixosConfigurations.heavens-door = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules =
        commonModules
        ++ desktopModules
        ++ [
          ./hosts/heavens-door/configuration.nix
        ];
    };
    nixosConfigurations.highway-star = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules =
        commonModules
        ++ desktopModules
        ++ [
          ./hosts/highway-star/configuration.nix
          nixos-hardware.nixosModules.framework-11th-gen-intel
        ];
    };
    nixosConfigurations.judgement = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules =
        commonModules
        ++ [
          ./hosts/judgement/configuration.nix
        ];
    };
    nixosConfigurations.super-fly = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules = commonModules ++ [./hosts/super-fly/configuration.nix];
    };
  };
}
