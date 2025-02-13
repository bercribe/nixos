{
  config,
  pkgs,
  lib,
  local,
  ...
}: let
  utils = local.utils {inherit config;};
in {
  systemd.timers.syncthing-healthcheck = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "syncthing-healthcheck.service";
    };
  };
  systemd.services.syncthing-healthcheck = {
    script = let
      slug = "${config.networking.hostName}-syncthing-ok";
    in ''
      apiKey=$(${lib.getExe pkgs.xq-xml} ${config.services.syncthing.configDir}/config.xml -x configuration/gui/apikey)
      response=$(${lib.getExe pkgs.curl} -H "X-API-Key: $apiKey" http://${config.services.syncthing.guiAddress}/rest/system/error)

      ${utils.writeHealthchecksLogScript slug} "$response"

      errors=$(echo "$response" | ${lib.getExe pkgs.jq} '.errors')
      if [[ "$errors" == "null" ]]; then
        ${utils.writeHealthchecksPingScript slug}
      fi
    '';
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
  };
}
