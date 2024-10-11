{
  self,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./base-client.nix
    (self + /modules/clients/local-healthchecks.nix)
  ];

  systemd.timers.ups-monitor = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "ups-monitor.service";
    };
  };
  systemd.services.ups-monitor = {
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      # will error out if not connected
      ${pkgs.nut}/bin/upsc ups@192.168.0.54

      pingKey="$(cat ${config.sops.secrets."healthchecks/local/ping-key".path})"
      ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "http://healthchecks.lan/ping/$pingKey/${config.networking.hostName}-ups-online"
    '';
  };
}
