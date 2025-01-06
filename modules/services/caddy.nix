{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.services.reverseProxy;
in {
  options.services.reverseProxy = {
    enable = lib.mkEnableOption "reverse proxy";

    services = with lib;
    with types;
      mkOption {
        type = attrsOf (submodule {
          options = {
            port = mkOption {
              type = nullOr int;
              default = null;
              description = "Local port service is hosted on";
            };
          };
        });
        default = {};
        example = {
          miniflux = {
            port = 9044;
          };
        };
        description = "Services to set up a reverse proxy for";
      };
  };

  config = let
    hostUrl = "${config.networking.hostName}.mawz.dev";
  in
    lib.mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = [80 443];

      # Certs
      sops.secrets."cloudflare/lego" = {
        sopsFile = self + /secrets/common.yaml;
      };
      security.acme = {
        acceptTerms = true;

        defaults = {
          email = "mawz@hey.com";
          group = config.services.caddy.group;

          dnsProvider = "cloudflare";
          credentialsFile = config.sops.secrets."cloudflare/lego".path;
        };

        certs = {
          "${hostUrl}" = {
            extraDomainNames = ["*.${hostUrl}"];
          };
        };
      };

      services.caddy = {
        enable = true;
        virtualHosts = let
          certDir = config.security.acme.certs."${hostUrl}".directory;
          hosts = with lib;
            listToAttrs (concatLists (mapAttrsToList (service: attrs: let
                url = "${service}.${hostUrl}";
              in [
                (nameValuePair "http://${service}.lan" {
                  extraConfig = ''
                    redir https://${url}{uri} permanent
                  '';
                })
                (nameValuePair url {
                  extraConfig = ''
                    reverse_proxy localhost:${toString attrs.port}
                    tls ${certDir}/cert.pem ${certDir}/key.pem
                  '';
                })
              ])
              cfg.services));
        in
          hosts;
      };
    };
}
