{self, ...}: {
  imports = [
    ./healthchecks.nix
    ./uptime-kuma.nix
    (self + /modules/clients/heartbeat-healthchecks.nix)
    (self + /modules/clients/email-healthchecks.nix)
  ];
}
