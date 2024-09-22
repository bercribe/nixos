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

    # encountered a bug with the version packaged in nixpkgs, version 0.7.0
    # it hangs and doesn't start the server, and won't respond to interrupts
    typst-live.url = "github:ItsEthra/typst-live?rev=6a0f70ae366c971d3f668a11e212dcd1580a838f";
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
    ];
    desktopModules = [
      ./modules/overlays.nix
      home-manager.nixosModules.home-manager
      stylix.nixosModules.stylix
    ];
  in {
    nixosConfigurations.mawz-hue = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules =
        commonModules
        ++ desktopModules
        ++ [
          ./hosts/mawz-hue/configuration.nix
        ];
    };
    nixosConfigurations.mawz-fw = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules =
        commonModules
        ++ desktopModules
        ++ [
          ./hosts/mawz-fw/configuration.nix
          nixos-hardware.nixosModules.framework-11th-gen-intel
        ];
    };
    nixosConfigurations.mawz-nuc = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules =
        commonModules
        ++ [
          ./hosts/mawz-nuc/configuration.nix
        ];
    };
    nixosConfigurations.mawz-vault = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = inputs;
      modules = [./hosts/mawz-vault/configuration.nix];
    };
  };
}
