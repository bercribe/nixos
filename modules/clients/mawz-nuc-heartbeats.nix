{
  config,
  pkgs,
  ...
}: {
  imports = [../sops.nix];

  sops.secrets."healthchecks/remote/ping-key" = {};

  systemd.timers.uptime-heartbeat = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "uptime-heartbeat.service";
    };
  };
  systemd.services.uptime-heartbeat = {
    script = ''
      pingKey="$(cat ${config.sops.secrets."healthchecks/remote/ping-key".path})"
      ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "https://hc-ping.com/$pingKey/mawz-nuc-online"
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
