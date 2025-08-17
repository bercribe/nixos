{
  description = "A NixOS configuration flake";

  inputs = {
    scripts = {
      url = "github:bercribe/scripts";
      flake = false;
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";
    stylix.url = "github:danth/stylix/release-25.05";

    paisa.url = "github:ananthakumaran/paisa";
  };

  outputs = {
    self,
    nixpkgs,
    nixos-hardware,
    home-manager,
    disko,
    sops-nix,
    stylix,
    paisa,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};

    specialArgs =
      inputs
      // {
        local = {
          constants = import ./constants;
          utils = pkgs.callPackage ./utils;
        };
      };

    commonModules = [
      home-manager.nixosModules.home-manager
      disko.nixosModules.disko
      sops-nix.nixosModules.sops
      stylix.nixosModules.stylix
    ];

    paisaModule = {...}: {
      nixpkgs.overlays = [
        (final: prev: {
          paisa-cli = paisa.packages."${system}".default;
        })
      ];
    };
  in {
    nixosConfigurations = {
      heavens-door = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules =
          commonModules
          ++ [
            ./hosts/heavens-door/configuration.nix
          ];
      };
      highway-star = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules =
          commonModules
          ++ [
            ./hosts/highway-star/configuration.nix
            nixos-hardware.nixosModules.framework-11th-gen-intel
          ];
      };
      judgement = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules =
          commonModules
          ++ [
            ./hosts/judgement/configuration.nix
          ];
      };
      moody-blues = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules =
          commonModules
          ++ [
            ./hosts/moody-blues/configuration.nix
          ];
      };
      super-fly = nixpkgs.lib.nixosSystem {
        inherit system specialArgs;
        modules =
          commonModules
          ++ [
            ./hosts/super-fly/configuration.nix
            paisaModule
          ];
      };
    };
    homeConfigurations = {
      "mawz@heavens-door" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./hosts/heavens-door/home.nix
        ];
      };
      "mawz@highway-star" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./hosts/highway-star/home.nix
        ];
      };
      "mawz@judgement" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./hosts/judgement/home.nix
        ];
      };
      "mawz@moody-blues" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./hosts/moody-blues/home.nix
        ];
      };
      "mawz@super-fly" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./hosts/super-fly/home.nix
        ];
      };
    };
  };
}
