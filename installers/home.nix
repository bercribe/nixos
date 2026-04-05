system: ''
  export XDG_CONFIG_HOME=$HOME/.config
  mkdir -p "$XDG_CONFIG_HOME/home-manager"
  cat > "$XDG_CONFIG_HOME/home-manager/flake.nix" <<EOF
  {
    description = "Home Manager configuration";

    inputs = {
      nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
      home-manager = {
        url = "github:nix-community/home-manager";
        inputs.nixpkgs.follows = "nixpkgs";
      };
      my-nix.url = "github:bercribe/nixos";
      errata.url = "github:bercribe/errata";
    };

    outputs = {nixpkgs, home-manager, my-nix, ...}: let
      overlays = [errata.overlays.default];
      pkgs = import nixpkgs {
        inherit overlays;
        system = "${system}";
        config.allowUnfree = true;
      };
    in {
      homeConfigurations."$USER" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        modules = [
          ./home.nix
          my-nix.homeModules.minimal
          errata.homeModules.session-tool
          {
            local.packages.includeScripts = true;
          }
        ];
      };
    };
  }
  EOF
  nix run home-manager/master -- init --switch
''
