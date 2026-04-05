{
  config,
  lib,
  ...
}: let
  cfg = config.local.microvm-client;
  vms = import ./vms.nix;
in {
  options.local.microvm-client = with lib; {
    enable = mkEnableOption "microvm SSH client config";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh.matchBlocks = lib.mapAttrs' (name: vm:
      lib.nameValuePair "${name}-microvm" {
        hostname = vm.ipAddress;
        extraOptions = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };
      })
    vms;
  };
}
