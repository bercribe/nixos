{
  config,
  lib,
  microvm,
  nixpkgs-unstable,
  home-manager,
  ...
}: let
  cfg = config.local.microvm;
  microvmBase = import ./microvm-base.nix;
in {
  # https://michael.stapelberg.ch/posts/2026-02-01-coding-agent-microvm-nix/
  # https://microvm-nix.github.io/microvm.nix/

  options.local.microvm = with lib;
  with types; {
    enable = mkEnableOption "microvm.nix";
    externalInterface = mkOption {
      type = str;
      description = "Main external interface name";
    };
  };

  config = lib.mkIf cfg.enable {
    # host network setup
    systemd.network.enable = true;

    systemd.network.netdevs."20-microbr".netdevConfig = {
      Kind = "bridge";
      Name = "microbr";
    };

    systemd.network.networks."20-microbr" = {
      matchConfig.Name = "microbr";
      addresses = [{Address = "192.168.83.1/24";}];
      networkConfig = {
        ConfigureWithoutCarrier = true;
      };
    };

    systemd.network.networks."21-microvm-tap" = {
      matchConfig.Name = "microvm*";
      networkConfig.Bridge = "microbr";
    };

    networking.nat = {
      enable = true;
      internalInterfaces = ["microbr"];
      externalInterface = cfg.externalInterface;
    };

    # TODO: consolidate IP declarations, make HM accessible
    home-manager.users.mawz.programs.ssh.matchBlocks.sources-microvm = {
      hostname = "192.168.83.2";
    };
    microvm.vms.sources = {
      autostart = false;
      config = {
        imports = [
          microvm.nixosModules.microvm
          (microvmBase {
            hostName = "sources";
            ipAddress = "192.168.83.2";
            tapId = "microvm2";
            mac = "02:00:00:00:00:02";
            workspace = "/home/mawz/sources/public";
            inherit
              nixpkgs-unstable
              home-manager
              ;
          })
          {
            home-manager.users.mawz.local.programs.st.directories = ["$HOME/sources/public"];
          }
        ];
      };
    };
  };
}
