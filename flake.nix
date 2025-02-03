{
  description = "A NixOS configuration flake";

  inputs = {
    scripts = {
      url = "github:bercribe/scripts";
      flake = false;
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    sops-nix.url = "github:Mic92/sops-nix";
    stylix.url = "github:danth/stylix/release-24.11";

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
    commonModules = [
      home-manager.nixosModules.home-manager
      disko.nixosModules.disko
      sops-nix.nixosModules.sops
    ];
    desktopModules = [
      stylix.nixosModules.stylix
    ];

    paisaModule = {...}: {
      nixpkgs.overlays = [
        (final: prev: {
          paisa-cli = paisa.packages."${system}".default;
        })
      ];
    };

    # need to build from source for CPUs that don't support AVX instruction set extensions
    frigateModule = {...}: {
      nixpkgs.overlays = [
        (final: prev: {
          frigate = prev.frigate.override {
            python312 = prev.python311.override {
              packageOverrides = pyfinal: pyprev: {
                tensorflow-bin = pyprev.tensorflow;
              };
            };
          };
        })
      ];
    };
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
    nixosConfigurations.moody-blues = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules =
        commonModules
        ++ [
          ./hosts/moody-blues/configuration.nix
          frigateModule
        ];
    };
    nixosConfigurations.super-fly = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules =
        commonModules
        ++ [
          ./hosts/super-fly/configuration.nix
          paisaModule
        ];
    };
  };
}
