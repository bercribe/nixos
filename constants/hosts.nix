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
          zfsEnabled = mkOption {
            type = bool;
            default = false;
            description = "Marks the host as a ZFS enabled host";
          };
          enableSyncoidBackups = mkOption {
            type = bool;
            default = false;
            description = "True to enable syncoid pull job from super-fly";
          };
          enableUps = mkOption {
            type = bool;
            default = false;
            description = "True to integrate this host with UPS monitoring";
          };
          macs = mkOption {
            type = listOf str;
            default = [];
            description = "Mac addresses";
          };
          syncthingId = mkOption {
            type = nullOr str;
            default = null;
            description = "Syncthing public key";
          };
        };
      });
    };

  config.local.constants.hosts = let
    hosts = {
      echoes = {
        domain = local.secret-attrs.personal-domain;
      };
      heavens-door = {
        zfsEnabled = true;
        syncthingId = "HK3YODK-63EFXRW-77XQ2PK-ZB5A35F-6BSAZ6S-J76VARS-KV6HJSN-D7KR4AB";
      };
      highway-star = {
        zfsEnabled = true;
        syncthingId = "EEM5E4H-7TFYA5Y-BY37H4D-25LOQIS-M5ETY2C-JSVJHOL-4O67NI3-CPZQ4AE";
      };
      judgement = {
        zfsEnabled = true;
        enableSyncoidBackups = true;
      };
      moody-blues = {
        zfsEnabled = true;
        enableSyncoidBackups = true;
      };
      super-fly = {
        zfsEnabled = true;
        enableSyncoidBackups = true;
        enableUps = true;
        macs = ["74:56:3c:e4:75:32"];
        syncthingId = "QL7YLXY-WKBMRND-BKQB6KN-Q4QI2MT-Z4RJXUS-JF7HJGE-PZ7D7Y2-B5RGJAV";
      };
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
        enableUps = true;
        macs = ["00:11:32:ea:02:ab" "00:11:32:ea:02:ac"];
        syncthingId = "XX5DKCN-4OTCVAB-2QWFVBN-NVIK24H-AENGONB-FQ67OPV-GITYMJY-55S6AAV";
      };
      geb = {syncthingId = "Z5BAWSH-SKUWWP7-AIPUJIT-FNB4E3U-4LDOCVV-XGZOBHO-VJ26EAB-XNHEFAF";};
      sethan = {syncthingId = "HXAAIQL-OXKK5KA-YCD6KGU-RBXLLM2-XIDKKVG-GA6PCSZ-C4MZHVK-2H7HNAO";};
      whitesnake = {syncthingId = "GAGOH5G-KBA557E-T7UVVKE-K2TYB5W-KRSCTUF-B6HU3UP-OZA3LAC-5S27BQI";};
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
