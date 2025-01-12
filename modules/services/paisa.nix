{pkgs, ...}: let
  user = "paisa";
  group = "ledger";
  dataDir = "/services/paisa";
  port = 7500;
in {
  systemd.services.paisa = {
    description = "paisa - ledger based personal finance manager";
    wantedBy = ["multi-user.target"];
    after = ["network.target"];
    serviceConfig = {
      # ExecStartPre = "${pkgs.paisa}/bin/paisa init";
      ExecStart = "${pkgs.paisa}/bin/paisa serve -p ${toString port}";
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
      ProcSubset = "pid";
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
      RestrictNamespaces = true;
      RestrictRealtime = true;
      RestrictSUIDSGID = true;
      SystemCallArchitectures = "native";
      SystemCallFilter = [
        "@system-service"
        "~@privileged"
        # "~@resources"
      ];
      UMask = "0077";
      User = user;
    };
  };
  users.users."${user}" = {
    description = "Paisa service owner";
    isSystemUser = true;
    inherit group;
  };
  users.groups."${group}" = {};

  services.reverseProxy = {
    enable = true;
    services.paisa = {
      inherit port;
    };
  };
}
