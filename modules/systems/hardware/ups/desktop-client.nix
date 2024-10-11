{
  self,
  config,
  pkgs,
  ...
}: {
  imports = [
    (self + /modules/sops.nix)
  ];

  sops.secrets."ups/observer" = {
    sopsFile = self + /secrets/common.yaml;
  };

  # shutdown machine automatically during power outage
  power.ups = let
    notifyCmd = pkgs.writeShellScript "notify-cmd" ''
      ${pkgs.util-linux}/bin/logger -t notify-cmd "$@"
    '';
  in {
    enable = true;
    mode = "netclient";
    upsmon = {
      settings = {
        MINSUPPLIES = 1;
        RUN_AS_USER = "root";
        SHUTDOWNCMD = "${pkgs.systemd}/bin/shutdown now";
        NOTIFYCMD = "${notifyCmd}";
        NOTIFYFLAG = [
          ["ONLINE" "SYSLOG+WALL+EXEC"]
          ["ONBATT" "SYSLOG+WALL+EXEC"]
          ["LOWBATT" "SYSLOG+WALL+EXEC"]
          ["FSD" "SYSLOG+WALL+EXEC"]
          ["COMMOK" "SYSLOG+WALL"]
          ["COMMBAD" "SYSLOG+WALL+EXEC"]
          ["SHUTDOWN" "SYSLOG+WALL+EXEC"]
          ["REPLBATT" "SYSLOG+WALL+EXEC"]
          ["NOCOMM" "SYSLOG+WALL+EXEC"]
          ["NOPARENT" "SYSLOG+WALL+EXEC"]
          ["CAL" "SYSLOG+WALL+EXEC"]
          ["NOTCAL" "SYSLOG+WALL+EXEC"]
          ["OFF" "SYSLOG+WALL+EXEC"]
          ["NOTOFF" "SYSLOG+WALL+EXEC"]
          ["BYPASS" "SYSLOG+WALL+EXEC"]
          ["NOTBYPASS" "SYSLOG+WALL+EXEC"]
        ];
      };
      monitor.cyberpower = {
        system = "ups@192.168.0.54";
        type = "secondary";
        user = "observer";
        passwordFile = config.sops.secrets."ups/observer".path;
      };
    };
  };
  # notifications
  systemd.user.services.ups-journal-notify = {
    after = ["network.target"];
    wantedBy = ["default.target"];
    description = "UPS Journal Entry Notification Service";
    serviceConfig = {
      Type = "simple";
    };
    script = ''
      journalctl -f -u upsmon.service -t notify-cmd | while read -r line; do
        ${pkgs.libnotify}/bin/notify-send -t 60000  UPS "$line"
      done
    '';
  };
}
