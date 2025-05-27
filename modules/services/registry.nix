{
  config,
  local,
  ...
}: let
  hosts = local.constants.hosts;
  judgement = hosts.judgement;
  moody-blues = hosts.moody-blues;
  super-fly = hosts.super-fly;
in {
  imports = [
    # http
    ./syncthing/headless.nix
    ./adguardhome.nix
    ./caddy.nix
    ./forgejo.nix
    ./frigate.nix
    ./hass.nix
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

  local.service-registry = {
    adguardhome = {
      shortName = "aghome";
      friendlyName = "adguard-home";
      hosts = [judgement moody-blues super-fly];
    };
    forgejo = {
      shortName = "forgejo";
      hosts = [judgement];
    };
    frigate = {
      shortName = "frigate";
      hosts = [judgement];
    };
    home-assistant = {
      shortName = "hass";
      hosts = [judgement];
    };
    homepage-dashboard = {
      shortName = "home";
      friendlyName = "homepage";
      hosts = [judgement];
    };
    immich = {
      shortName = "immich";
      hosts = [super-fly];
    };
    jellyfin = {
      shortName = "jellyfin";
      hosts = [super-fly];
    };
    karakeep = {
      shortName = "karakeep";
      hosts = [judgement];
    };
    miniflux = {
      shortName = "miniflux";
      hosts = [judgement];
    };
    paisa = {
      shortName = "paisa";
      hosts = [super-fly];
    };
    readeck = {
      shortName = "readeck";
      hosts = [judgement];
    };
    syncthing-headless = {
      shortName = "syncthing";
      friendlyName = "syncthing";
      hosts = [super-fly];
    };
  };
  local.services.monitoring.host = judgement;
}
