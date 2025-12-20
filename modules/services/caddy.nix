{
  config,
  lib,
  local,
  secrets,
  ...
}: let
  cfg = config.local.reverseProxy;
in {
  options.local.reverseProxy = {
    enable = lib.mkEnableOption "reverse proxy";

    useAcme = with lib;
    with types;
      mkOption {
        type = bool;
        default = true;
        description = "True to mange certs using ACME";
      };

    domainBase = with lib;
    with types;
      mkOption {
        type = str;
        default = "mawz.dev";
        description = "DNS base name";
      };

    localRedirectHost = with lib;
    with types;
      mkOption {
        type = str;
        description = "Host to redirect from *.local.mawz.dev";
      };

    services = with lib;
    with types;
      mkOption {
        type = attrsOf (submodule {
          options = {
            address = mkOption {
              type = str;
              default = "localhost";
              description = "Local adress service is hosted on";
            };
            port = mkOption {
              type = int;
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
            httpsBackend = mkOption {
              type = bool;
              default = false;
              description = "https://caddyserver.com/docs/caddyfile/directives/reverse_proxy#https";
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
    hostUrl = "${hostName}.${cfg.domainBase}";
    isLocalRedirHost = cfg.localRedirectHost == config.networking.hostName;
    localRedirUrl = "lan.${cfg.domainBase}";
  in
    lib.mkIf cfg.enable {
      networking.firewall.allowedTCPPorts = [80 443] ++ (with lib; concatLists (mapAttrsToList (_: {additionalPorts, ...}: map ({from, ...}: from) additionalPorts) cfg.services));

      # Certs
      sops.secrets."cloudflare/lego" = lib.mkIf cfg.useAcme {
        sopsFile = secrets + /sops/local.yaml;
      };
      security.acme = lib.mkIf cfg.useAcme {
        acceptTerms = true;

        defaults = {
          email = local.secrets.email;
          group = config.services.caddy.group;

          dnsProvider = "cloudflare";
          credentialsFile = config.sops.secrets."cloudflare/lego".path;

          # possible fix for:
          # Could not validate ARI 'replaces' field :: requester account did not request the certificate being replaced by this order
          extraLegoRenewFlags = ["--ari-disable"];
        };

        certs = let
        in {
          "${hostUrl}" = {
            extraDomainNames = ["*.${hostUrl}"];
            reloadServices = ["caddy"];
          };
          "${localRedirUrl}" = lib.mkIf isLocalRedirHost {
            extraDomainNames = ["*.${localRedirUrl}"];
            reloadServices = ["caddy"];
          };
        };
      };

      services.caddy = {
        enable = true;
        # home assistant mobile app SSL failing with HTTP/3
        globalConfig = ''
          servers {
            protocols h1 h2
          }
        '';
        virtualHosts = let
          tlsConf = certDir: lib.optionalString cfg.useAcme "tls ${certDir}/cert.pem ${certDir}/key.pem";

          hostCertDir = config.security.acme.certs.${hostUrl}.directory;
          reverseProxies = with lib;
            listToAttrs (concatLists (mapAttrsToList (service: attrs: let
              shortName = config.local.service-registry."${service}".shortName;
              url = "${shortName}.${hostUrl}";
              caddyCfg = proxyUrl: ''
                ${tlsConf hostCertDir}
                reverse_proxy ${proxyUrl} {
                  ${
                  if attrs.httpsBackend
                  then "header_up Host {upstream_hostport}"
                  else ""
                }
                }
              '';

              lanRedir =
                nameValuePair "http://${shortName}${
                  if attrs.unique
                  then ""
                  else ".${hostName}"
                }.lan" {
                  extraConfig = ''
                    redir https://${url}{uri} 308
                  '';
                };
              reverseProxy = nameValuePair url {
                extraConfig = caddyCfg "http://${attrs.address}:${toString attrs.port}";
              };
              additionalPorts =
                map
                (
                  {
                    from,
                    to,
                  }: (nameValuePair "${url}:${toString from}" {
                    extraConfig = caddyCfg "http://${attrs.address}:${toString to}";
                  })
                )
                attrs.additionalPorts;
            in
              [
                lanRedir
                reverseProxy
              ]
              ++ additionalPorts)
            cfg.services));

          localCertDir = config.security.acme.certs.${localRedirUrl}.directory;
          localRedirects =
            if isLocalRedirHost
            then let
              uniqueServices = with lib; filterAttrs (_: {hosts, ...}: (length hosts) == 1) config.local.service-registry;
            in
              with lib;
                listToAttrs (mapAttrsToList (service: {
                    shortName,
                    hosts,
                    ...
                  }: (nameValuePair "https://${shortName}.${localRedirUrl}" {
                    extraConfig = ''
                      ${tlsConf localCertDir}
                      redir https://${shortName}.${head hosts}.${cfg.domainBase}{uri} 308
                    '';
                  }))
                  uniqueServices)
            else {};
        in
          reverseProxies // localRedirects;
      };
    };
}
