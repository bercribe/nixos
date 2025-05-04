{
  config,
  lib,
  ...
}: let
  cfg = config.local.service-registry;
in {
  imports = [
    ./monitoring
    ./syncthing/headless.nix
    ./adguardhome.nix
    ./caddy.nix
    ./forgejo.nix
    ./frigate.nix
    ./hass.nix
    ./immich.nix
    ./jellyfin.nix
    ./miniflux.nix
    ./paisa.nix
    ./postfix.nix
    ./postgresql.nix
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
          hosts = mkOption {
            type = listOf str;
            description = "Hostnames of hosts running service";
          };
        };
      });
    };

  config = {
    local.services = let
      host = config.networking.hostName;
    in
      with lib; mapAttrs (service: {hosts, ...}: {enable = elem host hosts;}) cfg;

    local.reverseProxy = {
      services = with lib;
        listToAttrs (mapAttrsToList (service: {hosts, ...}: (nameValuePair service {unique = (length hosts) == 1;}))
          cfg);
    };
  };
}
