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
  local.service-registry = {
    adguardhome = {
      shortName = "aghome";
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
    immich = {
      shortName = "immich";
      hosts = [super-fly];
    };
    jellyfin = {
      shortName = "jellyfin";
      hosts = [super-fly];
    };
    miniflux = {
      shortName = "miniflux";
      hosts = [judgement];
    };
    paisa = {
      shortName = "paisa";
      hosts = [super-fly];
    };
    syncthing-headless = {
      shortName = "syncthing";
      hosts = [super-fly];
    };
  };
  local.services.monitoring.host = judgement;
}
