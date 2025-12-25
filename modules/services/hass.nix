{
  config,
  pkgs,
  lib,
  local-utils,
  ...
}: let
  cfg = config.local.services.home-assistant;
  utils = local-utils;

  dataDir = "/services/hass";
in {
  options.local.services.home-assistant.enable = lib.mkEnableOption "home-assistant";

  config = lib.mkIf cfg.enable {
    hardware.bluetooth.enable = true;

    sops.secrets."hass/secrets" = {
      owner = "hass";
      path = "${dataDir}/secrets.yaml";
    };
    services.home-assistant = {
      enable = true;
      configDir = dataDir;
      extraComponents = let
        base = [
          # Components required to complete the onboarding
          "analytics"
          "google_translate"
          "met"
          "radio_browser"
          "shopping_list"
          # Recommended for fast zlib compression
          # https://www.home-assistant.io/integrations/isal
          "isal"
        ];
      in
        base
        # found here: https://github.com/NixOS/nixpkgs/blob/master/pkgs/servers/home-assistant/component-packages.nix
        ++ [
          "brother"
          "dlna_dmr"
          "cast"
          "esphome"
          "google_translate"
          "homeassistant_hardware"
          "ibeacon"
          "idasen_desk"
          "improv_ble"
          "ipp"
          "mobile_app"
          "mqtt"
          "nexia"
          "radio_browser"
          "samsungtv"
          "schlage"
          "sonos"
          "switchbot"
          "synology_dsm"
          "wyoming"
          "yolink"
          "zha"
        ];
      customComponents = with pkgs.home-assistant-custom-components; [
        frigate
      ];
      config = {
        # Includes dependencies for a basic setup
        # https://www.home-assistant.io/integrations/default_config/
        default_config = {};
        homeassistant = let
          url = utils.localHostUrl "home-assistant";
        in {
          internal_url = url;
          external_url = url;
          name = "Home";
          latitude = "!secret home_lat";
          longitude = "!secret home_lon";
        };
        http = {
          use_x_forwarded_for = true;
          trusted_proxies = ["::1"];
        };
        rest_command.ping_healthchecks = {
          url = "!secret healthchecks_url";
          method = "GET";
        };
        wake_on_lan = {};

        "automation nixos" = [
        ];
        "scene nixos" = [
        ];
        "script nixos" = [
        ];
        "automation ui" = "!include automations.yaml";
        "scene ui" = "!include scenes.yaml";
        "script ui" = "!include scripts.yaml";
      };
    };

    sops.secrets."mosquitto/hass" = {};
    sops.secrets."mosquitto/frigate" = {};
    services.mosquitto = {
      enable = true;
      # logType = ["all"];
      listeners = [
        {
          acl = ["pattern readwrite #"];
          users = {
            hass = {
              passwordFile = config.sops.secrets."mosquitto/hass".path;
            };
            frigate = {
              passwordFile = config.sops.secrets."mosquitto/frigate".path;
            };
          };
        }
      ];
    };

    # for voice assistant
    services.wyoming = {
      piper.servers.hass-piper = {
        enable = true;
        uri = "tcp://127.0.0.1:10200";
        voice = "en-us-ryan-medium";
      };
      faster-whisper.servers.hass-whisper = {
        enable = true;
        uri = "tcp://127.0.0.1:10300";
        language = "en";
      };
    };

    local.reverseProxy = {
      enable = true;
      services.home-assistant = {
        port = config.services.home-assistant.config.http.server_port;
      };
    };
  };
}
