{self, ...}: {
  imports = [
    ./healthchecks.nix
    ./uptime-kuma.nix
    (self + /modules/clients/healthchecks-heartbeats.nix)
    (self + /modules/clients/healthchecks-emails.nix)
  ];
}
