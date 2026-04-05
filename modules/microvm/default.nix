{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.local.microvm;
  microvmBase = import ./microvm-base.nix;
  vms = import ./vms.nix;
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

    microvm.vms = let
      makeVm = hostName: vm: {
        autostart = false;
        config = {
          imports = [
            inputs.microvm.nixosModules.microvm
            (microvmBase {
              inherit hostName inputs;
              inherit (vm) ipAddress tapId mac workspace;
            })
          ];
        };
      };
    in
      lib.mapAttrs makeVm vms;
  };
}
