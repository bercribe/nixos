{
  pkgs,
  lib,
  ...
}: let
  user = "paisa";
  group = "ledger";
  dataDir = "/services/paisa";
  port = 7500;

  paisa-fhs = pkgs.buildFHSEnv {
    name = "paisa";
    targetPkgs = pkgs:
      with pkgs; [
        ledger
        paisa-cli
      ];
    runScript = "paisa";
    meta.mainProgram = "paisa";
  };
in {
  # environment.systemPackages = [paisa-fhs];

  systemd.services.paisa = {
    description = "Paisa - ledger based personal finance manager";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    path = [paisa-fhs];

    serviceConfig = {
      ExecStart = "${lib.getExe paisa-fhs} serve -p ${toString port}";
      WorkingDirectory = dataDir;
      ReadWritePaths = dataDir;

      # Hardening
      # `systemd-analyze security paisa`
      CapabilityBoundingSet = [""];
      DeviceAllow = [""];
      LockPersonality = true;
      MemoryDenyWriteExecute = true;
      NoNewPrivileges = true;
      PrivateDevices = true;
      PrivateTmp = true;
      PrivateUsers = true;
      # ProcSubset = "pid";
      ProtectClock = true;
      ProtectControlGroups = true;
      ProtectHome = true;
      ProtectHostname = true;
      ProtectKernelLogs = true;
      ProtectKernelModules = true;
      ProtectKernelTunables = true;
      ProtectProc = "invisible";
      ProtectSystem = "strict";
      RemoveIPC = true;
      RestrictAddressFamilies = [
        "AF_INET"
        "AF_INET6"
        "AF_UNIX"
      ];
      RestrictNamespaces = ["user" "mnt"]; # allow buildFHSEnv
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        # "@system-service"
        "~@clock"
        "~@cpu-emulation"
        "~@debug"
        "~@module"
        # "~@mount"
        "~@obsolete"
        # "~@privileged"
        "~@raw-io"
        "~@reboot"
        # "~@resources"
        "~@swap"
      ];
      UMask = "0077";
      User = user;
    };
  };

  users.users."${user}" = {
    description = "Paisa service owner";
    isSystemUser = true;
    inherit group;
    home = dataDir;
  };
  users.groups."${group}" = {};

  services.reverseProxy = {
    enable = true;
    services.paisa = {
      inherit port;
    };
  };
}
