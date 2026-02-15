{lib, ...}: let
  echoes = "echoes";
  judgement = "judgement";
  moody-blues = "moody-blues";
  super-fly = "super-fly";
  monitorHost = judgement;
in {
  options.local.constants.service-registry = with lib;
  with types;
    mkOption {
      type = attrsOf (submodule {
        options = {
          shortName = mkOption {
            type = str;
            description = "Used to generate URL";
          };
          friendlyName = mkOption {
            type = str;
            default = null;
            description = "Used in place of service name when generating names";
          };
          hosts = mkOption {
            type = listOf str;
            description = "Hostnames of hosts running service";
          };
        };
      });
    };

  config.local.constants.service-registry = let
    registry = {
      adguardhome = {
        shortName = "aghome";
        friendlyName = "adguard-home";
        hosts = [judgement super-fly];
      };
      forgejo = {
        hosts = [judgement];
      };
      frigate = {
        hosts = [judgement];
      };
      gatus = {
        hosts = [monitorHost];
      };
      healthchecks = {
        hosts = [monitorHost];
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
        hosts = [super-fly];
      };
      jellyfin = {
        hosts = [super-fly];
      };
      karakeep = {
        hosts = [judgement];
      };
      kodi = {
        hosts = [];
      };
      miniflux = {
        hosts = [judgement];
      };
      # TODO: https://github.com/ananthakumaran/paisa/issues/343
      # paisa = {
      #   hosts = [super-fly];
      # };
      readeck = {
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
    };
  in
    with lib;
      mapAttrs (name: value:
        value
        // {
          shortName = value.shortName or name;
          friendlyName = value.friendlyName or name;
        })
      registry;
}
