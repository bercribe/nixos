{
  config,
  lib,
  pkgs,
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

    # Stop/start VMs on sleep/resume to prevent virtiofs ESTALE errors.
    # virtiofs doesn't survive host suspend even with VM paused.
    powerManagement = let
      vmNames = lib.attrNames vms;
      stateDir = "/run/microvm-suspend";
      systemctl = "${pkgs.systemd}/bin/systemctl";
    in {
      powerDownCommands = ''
        mkdir -p ${stateDir}
        rm -f ${stateDir}/*
        ${lib.concatMapStringsSep "\n" (name: ''
            if ${systemctl} is-active --quiet microvm@${name}.service; then
              touch ${stateDir}/${name}
              ${systemctl} stop microvm@${name}.service
            fi
          '')
          vmNames}
      '';
      resumeCommands = ''
        ${lib.concatMapStringsSep "\n" (name: ''
            if [ -f ${stateDir}/${name} ]; then
              ${systemctl} start microvm@${name}.service
            fi
          '')
          vmNames}
        rm -rf ${stateDir}
      '';
    };

    home-manager.users.mawz.local.microvm-client.enable = true;

    sops.secrets."models/anthropic" = {
      owner = "mawz";
    };
  };
}
