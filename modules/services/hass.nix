{
  config,
  pkgs,
  ...
}: let
  dataDir = "/services/hass";
in {
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
      ++ [
        "brother"
        "dlna_dmr"
        "cast"
        "esphome"
        "google_translate"
        "ibeacon"
        "idasen_desk"
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
        "yolink"
      ];
    customComponents = with pkgs.home-assistant-custom-components; [
      frigate
    ];
    config = {
      # Includes dependencies for a basic setup
      # https://www.home-assistant.io/integrations/default_config/
      default_config = {};
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

  local.reverseProxy = {
    enable = true;
    services.hass = {
      port = config.services.home-assistant.config.http.server_port;
    };
  };
}
