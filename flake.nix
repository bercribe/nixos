{
  description = "A NixOS configuration flake";

  inputs = {
    errata = {
      url = "github:bercribe/errata";
      flake = false;
    };
    secrets = {
      url = "git+ssh://git@github.com/bercribe/secrets.git";
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
    nixpkgs,
    nixos-hardware,
    home-manager,
    disko,
    sops-nix,
    stylix,
    paisa,
    secrets,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    overlay = import ./overlay.nix inputs;
    pkgs = import nixpkgs {
      inherit system;
      overlays = [overlay];
      config.allowUnfree = true;
    };

    local = {
      constants = pkgs.callPackage ./constants {};
      utils = pkgs.callPackage ./utils;
      secrets = import (secrets + /nix);
    };
    specialArgs =
      inputs
      // {
        inherit local;
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

    homeInstaller = import ./home-installer.nix;
    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f:
      builtins.listToAttrs (map (system: {
          name = system;
          value = f system;
        })
        systems);
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
    homeConfigurations = let
      commonModules = [
        stylix.homeModules.stylix
      ];

      extraSpecialArgs = {
        inherit local;
      };
    in {
      "mawz@heavens-door" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules =
          commonModules
          ++ [
            ./hosts/heavens-door/home.nix
          ];
      };
      "mawz@highway-star" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules =
          commonModules
          ++ [
            ./hosts/highway-star/home.nix
          ];
      };
      "mawz@judgement" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules =
          commonModules
          ++ [
            ./hosts/judgement/home.nix
          ];
      };
      "mawz@moody-blues" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules =
          commonModules
          ++ [
            ./hosts/moody-blues/home.nix
          ];
      };
      "mawz@super-fly" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules =
          commonModules
          ++ [
            ./hosts/super-fly/home.nix
          ];
      };
    };

    # portable dev environment
    homeModules = let
      minimal = import ./modules/systems/home/minimal.nix;
    in {
      default = minimal;
      inherit minimal;
    };
    apps = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      install = {
        type = "app";
        program = "${pkgs.writeShellScript "install" (homeInstaller system)}";
      };
    });
    devShells = forAllSystems (system: let
      pkgs = nixpkgs.legacyPackages.${system};
      minimal = pkgs.mkShell {
        shellHook = ''
          home=$HOME
          export HOME=$TMP
          export PATH=$TMP/.nix-profile/bin:$PATH
          ${homeInstaller system}
          export HOME=$home
        '';
      };
    in {
      default = minimal;
      inherit minimal;
    });
    overlays.default = overlay;
  };
}
