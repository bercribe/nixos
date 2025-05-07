{
  config,
  lib,
  ...
}: let
  cfg = config.local.service-registry;
in {
  imports = [
    ./registry.nix
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
    localServices = with lib; filterAttrs (_: {hosts, ...}: (elem host hosts)) cfg;
  in {
    local.services = with lib; mapAttrs (service: {hosts, ...}: {enable = elem host hosts;}) cfg;

    local.reverseProxy.services = with lib;
      listToAttrs (mapAttrsToList (service: {hosts, ...}: (nameValuePair service {unique = (length hosts) == 1;}))
        localServices);
  };
}
