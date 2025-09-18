{
  self,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.local.services.gatus;
  port = 55310;
in {
  options.local.services.gatus.enable = lib.mkEnableOption "gatus";

  config = lib.mkIf cfg.enable {
    local.services.postfix.enable = true;

    sops.secrets."healthchecks/remote/ping-key" = {};
    sops.templates."gatus.env".content = ''
      UPSTREAM_HEALTHCHECKS_PING_KEY=${config.sops.placeholder."healthchecks/remote/ping-key"}
    '';

    services.gatus = {
      enable = true;
      settings = {
        web.port = port;
        alerting.email = {
          from = ''"Gatus" <noreply@gatus.lan>'';
          host = "localhost";
          port = 25;
          to = "mawz@hey.com";
        };
        endpoints = let
          makeEndpoint = site:
            {
              conditions = ["[STATUS] == 200"];
              alerts = [
                {
                  type = "email";
                }
              ];
            }
            // site;

          customEndpoints = map makeEndpoint [
            {
              name = "portfolio";
              url = "https://mawz.dev";
              group = "public";
            }
            {
              name = "project zoran";
              url = "https://projectzoran.com";
              group = "public";
            }
            {
              name = "synology DSM";
              url = "https://mr-president.lan:5001";
              group = "lan";
              client.insecure = true;
            }
            {
              name = "jet kvm";
              url = "http://notorious-big.lan";
              group = "lan";
            }
            {
              name = "main router";
              url = "http://hierophant-green.lan";
              group = "lan";
            }
            {
              name = "office switch";
              url = "http://hermit-purple.lan";
              group = "lan";
              conditions = ["[STATUS] == 401"];
            }
            {
              name = "upstream healthchecks.io ping";
              url = "https://hc-ping.com/\${UPSTREAM_HEALTHCHECKS_PING_KEY}/gatus-online?create=1";
              group = "monitoring";
            }
          ];

          registryOverrides = {
            kodi = {
              conditions = ["[STATUS] == 401"];
            };
          };

          registryEndpoints = with lib;
            concatLists (mapAttrsToList (service: {
              shortName,
              hosts,
              ...
            }:
              map (host: let
                isUnique = length hosts == 1;
              in
                makeEndpoint ({
                    name = "${service} (${host})";
                    group =
                      if isUnique
                      then host
                      else shortName;
                    url = "http://${shortName}${
                      if isUnique
                      then ""
                      else ".${host}"
                    }.lan";
                  }
                  // (registryOverrides.${service} or {})))
              hosts)
            config.local.service-registry);
        in
          customEndpoints ++ registryEndpoints;
      };
      environmentFile = config.sops.templates."gatus.env".path;
    };

    local.reverseProxy = {
      enable = true;
      services.gatus.port = port;
    };
  };
}
