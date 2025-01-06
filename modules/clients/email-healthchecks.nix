{
  self,
  config,
  pkgs,
  ...
}: {
  imports = [
    (self + /modules/services/postfix.nix)
  ];

  sops.secrets."healthchecks/remote/email-receiver" = {};

  systemd.timers.email-heartbeat = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "1h";
      OnUnitActiveSec = "1h";
      Unit = "email-heartbeat.service";
    };
  };
  systemd.services.email-heartbeat = {
    script = ''
      receiver="$(cat ${config.sops.secrets."healthchecks/remote/email-receiver".path})"
      echo "Email notifs good!" | ${pkgs.postfix}/bin/sendmail $receiver
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
