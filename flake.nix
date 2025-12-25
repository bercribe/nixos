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
    overlay = import ./overlay.nix inputs;

    pkgsF = system:
      import nixpkgs {
        inherit system;
        overlays = [overlay];
        config.allowUnfree = true;
      };
    local = {
      secrets = import (secrets + /nix);
    };

    homeInstaller = import ./installers/home.nix;

    systems = ["x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin"];
    forAllSystems = f:
      builtins.listToAttrs (map (system: {
          name = system;
          value = f system;
        })
        systems);
  in {
    nixosConfigurations = let
      commonModules = [
        home-manager.nixosModules.home-manager
        disko.nixosModules.disko
        sops-nix.nixosModules.sops
        stylix.nixosModules.stylix
        ./constants
        ./utils
      ];

      makeConfig = {
        system,
        hostname,
        properties,
      }: let
        specialArgs =
          inputs
          // {
            inherit local;
          };
        extraModules = properties.extraModules or [];
      in {
        name = hostname;
        value = nixpkgs.lib.nixosSystem {
          inherit system specialArgs;
          modules =
            commonModules
            ++ [
              ./hosts/${hostname}/configuration.nix
            ]
            ++ extraModules;
        };
      };
      makeConfigs = system: hosts: (builtins.listToAttrs (map (hostname:
        makeConfig {
          inherit system hostname;
          properties = hosts.${hostname};
        }) (builtins.attrNames hosts)));

      x86Linux = let
        system = "x86_64-linux";
      in
        makeConfigs system {
          heavens-door = {};
          highway-star.extraModules = [
            nixos-hardware.nixosModules.framework-11th-gen-intel
          ];
          judgement = {};
          moody-blues = {};
          super-fly.extraModules = [
            {
              nixpkgs.overlays = [
                (final: prev: {
                  paisa-cli = paisa.packages.${system}.default;
                })
              ];
            }
          ];
        };
      aarchLinux = let
        system = "aarch64-linux";
      in
        (makeConfigs system {
          echoes = {};
        })
        // {
          hetzner-cloud = nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              disko.nixosModules.disko
              ./installers/hetzner/configuration.nix
            ];
          };
        };
    in
      x86Linux // aarchLinux;

    homeConfigurations = let
      commonModules = [
        stylix.homeModules.stylix
        ./constants
        ./utils
      ];

      makeConfig = {
        system,
        hostname,
      }: let
        extraSpecialArgs = {
          inherit local;
        };
        pkgs = pkgsF system;
      in {
        name = "mawz@${hostname}";
        value = home-manager.lib.homeManagerConfiguration {
          inherit pkgs extraSpecialArgs;
          modules =
            commonModules
            ++ [
              ./hosts/${hostname}/home.nix
            ];
        };
      };
      makeConfigs = system: hosts: (builtins.listToAttrs (map (hostname: makeConfig {inherit system hostname;}) hosts));

      x86Linux = makeConfigs "x86_64-linux" [
        "heavens-door"
        "highway-star"
        "judgement"
        "moody-blues"
        "super-fly"
      ];
      aarchLinux = makeConfigs "aarch64-linux" ["echoes"];
    in
      x86Linux // aarchLinux;

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
