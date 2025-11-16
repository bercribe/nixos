{
  config,
  pkgs,
  ...
}: {
  imports = [
    ./base-client.nix
  ];

  # shutdown machine automatically during power outage
  power.ups.upsmon.settings = let
    notifyCmd = pkgs.writeShellScript "notify-cmd" ''
      ${pkgs.util-linux}/bin/logger -t notify-cmd "$@"
    '';
  in {
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

  # notifications
  systemd.user.services.ups-journal-notify = {
    after = ["network.target"];
    wantedBy = ["default.target"];
    description = "UPS Journal Entry Notification Service";
    serviceConfig = {
      Type = "simple";
    };
    script = ''
      journalctl -f -u upsmon.service -t notify-cmd -o cat | while read -r line; do
        ${pkgs.libnotify}/bin/notify-send -t 60000  UPS "$line"
      done
    '';
  };
}
