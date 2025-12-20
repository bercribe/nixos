let
  hosts = import ./hosts.nix;
  echoes = hosts.echoes;
  judgement = hosts.judgement;
  moody-blues = hosts.moody-blues;
  super-fly = hosts.super-fly;
in {
  adguardhome = {
    shortName = "aghome";
    friendlyName = "adguard-home";
    hosts = [judgement super-fly];
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
  hledger-web = {
    shortName = "ledger";
    friendlyName = "hledger";
    hosts = [super-fly];
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
  kodi = {
    shortName = "kodi";
    hosts = [moody-blues];
  };
  miniflux = {
    shortName = "miniflux";
    hosts = [judgement];
  };
  # TODO: https://github.com/ananthakumaran/paisa/issues/343
  # paisa = {
  #   shortName = "paisa";
  #   hosts = [super-fly];
  # };
  readeck = {
    shortName = "readeck";
    hosts = [judgement];
  };
  sftpgo = {
    shortName = "files";
    hosts = [echoes];
  };
  syncthing-headless = {
    shortName = "syncthing";
    friendlyName = "syncthing";
    hosts = [super-fly];
  };
}
