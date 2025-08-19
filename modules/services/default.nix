{
  config,
  lib,
  local,
  ...
}: let
  cfg = config.local.service-registry;
  judgement = local.constants.hosts.judgement;
in {
  imports = [
    # http
    ./syncthing/headless.nix
    ./adguardhome.nix
    ./caddy.nix
    ./forgejo.nix
    ./frigate.nix
    ./hass.nix
    ./hledger-web.nix
    ./homepage.nix
    ./immich.nix
    ./jellyfin.nix
    ./karakeep.nix
    ./miniflux.nix
    ./paisa.nix
    ./readeck.nix
    # monitoring
    ./monitoring
    # other
    ./postfix.nix
    ./postgresql.nix
  ];

  options.local.service-registry = with lib;
  with types;
    mkOption {
      type = attrsOf (submodule {
        options = {
          shortName = mkOption {
            type = str;
            description = "Used to generate URL";
          };
          friendlyName = mkOption {
            type = nullOr str;
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

  config = let
    host = config.networking.hostName;
    # services running on this machine
    localServices = with lib; filterAttrs (_: {hosts, ...}: (elem host hosts)) cfg;
  in {
    local.service-registry = local.constants.registry;
    local.service-monitoring.host = judgement;

    local.services = with lib; mapAttrs (service: {hosts, ...}: {enable = true;}) localServices;

    local.reverseProxy.services = with lib;
      listToAttrs (mapAttrsToList (service: {hosts, ...}: (nameValuePair service {unique = (length hosts) == 1;}))
        localServices);
  };
}
