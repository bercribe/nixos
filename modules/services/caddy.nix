{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.local.reverseProxy;
in {
  options.local.reverseProxy = {
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
            additionalPorts = mkOption {
              type = listOf (submodule {
                options = {
                  from = mkOption {
                    type = int;
                  };
                  to = mkOption {
                    type = int;
                  };
                };
              });
              default = [];
              description = "Additional port mappings";
            };
            unique = mkOption {
              type = bool;
              default = true;
              description = "True to use <service>.lan as URL, false for <service>.<hostName>.lan";
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
    hostName = config.networking.hostName;
    hostUrl = "${hostName}.mawz.dev";
  in
    lib.mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = [80 443] ++ (with lib; concatLists (mapAttrsToList (_: {additionalPorts, ...}: map ({from, ...}: from) additionalPorts) cfg.services));

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
            in
              [
                (nameValuePair "http://${service}${
                    if attrs.unique
                    then ""
                    else ".${hostName}"
                  }.lan" {
                    extraConfig = ''
                      redir https://${url}{uri} permanent
                    '';
                  })
                (nameValuePair url {
                  extraConfig = ''
                    reverse_proxy http://localhost:${toString attrs.port} {
                      header_up Host {upstream_hostport}
                    }
                    tls ${certDir}/cert.pem ${certDir}/key.pem
                  '';
                })
              ]
              ++ map
              (
                {
                  from,
                  to,
                }: (nameValuePair "${url}:${toString from}" {
                  extraConfig = ''
                    reverse_proxy http://localhost:${toString to} {
                      header_up Host {upstream_hostport}
                    }
                    tls ${certDir}/cert.pem ${certDir}/key.pem
                  '';
                })
              )
              attrs.additionalPorts)
            cfg.services));
        in
          hosts;
      };
    };
}
