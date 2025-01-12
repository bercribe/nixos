{self, ...}: {
  imports = [
    ./healthchecks.nix
    ./uptime-kuma.nix
    (self + /modules/cron/heartbeat-healthchecks.nix)
    (self + /modules/cron/email-healthchecks.nix)
  ];
}
