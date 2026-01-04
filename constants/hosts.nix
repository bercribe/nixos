{
  lib,
  local,
  ...
}: {
  options.local.constants.hosts = with lib;
  with types;
    mkOption {
      type = attrsOf (submodule {
        options = {
          domain = mkOption {
            type = str;
            default = "mawz.dev";
            description = "DNS base name for host";
          };
          friendlyName = mkOption {
            type = str;
            description = "Description used for monitoring";
          };
          icon = mkOption {
            type = str;
            description = "Icon used for homepage";
          };
          enableSsl = mkOption {
            type = bool;
            default = true;
            description = "Whether to use https or http for URL";
          };
          port = mkOption {
            type = nullOr number;
            default = null;
            description = "Used to specify a port different from the default";
          };
          lanDomain = mkOption {
            type = bool;
            default = false;
            description = "Whether to use .lan base domain for constructed URLs";
          };
          enableMonitoring = mkOption {
            type = bool;
            default = false;
            description = "Enable gatus monitoring for the host base domain";
          };
          createBookmark = mkOption {
            type = bool;
            default = false;
            description = "Bookmark the base domain on homepage";
          };
        };
      });
    };

  config.local.constants.hosts = let
    hosts = {
      echoes = {
        domain = local.secrets.personal-domain;
      };
      heavens-door = {};
      highway-star = {};
      judgement = {};
      moody-blues = {};
      super-fly = {};
      hierophant-green = {
        friendlyName = "router";
        icon = "mikrotik";
        enableSsl = false;
        lanDomain = true;
        enableMonitoring = true;
        createBookmark = true;
      };
      hermit-purple = {
        friendlyName = "office switch";
        icon = "netgear";
        enableSsl = false;
        lanDomain = true;
        enableMonitoring = true;
        createBookmark = true;
      };
      lovers = {
        friendlyName = "pikvm";
        enableMonitoring = true;
        createBookmark = true;
      };
      notorious-big = {
        friendlyName = "jetkvm";
        enableSsl = false;
        lanDomain = true;
        enableMonitoring = true;
        createBookmark = true;
      };
      mr-president = {
        friendlyName = "synology NAS";
        icon = "synology";
        port = 5001;
        lanDomain = true;
        enableMonitoring = true;
        createBookmark = true;
      };
    };
  in
    with lib;
      mapAttrs (name: value:
        value
        // {
          friendlyName = value.friendlyName or name;
          icon = value.icon or value.friendlyName or name;
        })
      hosts;
}
