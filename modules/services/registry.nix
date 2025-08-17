{
  config,
  local,
  ...
}: let
  hosts = local.constants.hosts;
  judgement = hosts.judgement;
in {
  imports = [
    # http
    ./syncthing/headless.nix
    ./adguardhome.nix
    ./caddy.nix
    ./forgejo.nix
    ./frigate.nix
    ./hass.nix
    ./hledger-web.nix
    ./homepage.nix
    ./immich.nix
    ./jellyfin.nix
    ./karakeep.nix
    ./miniflux.nix
    ./paisa.nix
    ./readeck.nix
    # monitoring
    ./monitoring
    # other
    ./postfix.nix
    ./postgresql.nix
  ];

  local.service-registry = local.constants.registry;
  local.services.monitoring.host = judgement;
}
