{
  config,
  lib,
  ...
}: let
  cfg = config.local.constants.service-registry;
  judgement = "judgement";
in {
  imports = [
    # http
    ./adguardhome.nix
    ./caddy.nix
    ./forgejo.nix
    ./frigate.nix
    ./gatus.nix
    ./hass.nix
    ./healthchecks.nix
    ./hledger-web.nix
    ./homepage.nix
    ./immich.nix
    ./jellyfin.nix
    ./karakeep.nix
    ./miniflux.nix
    ./paisa.nix
    ./readeck.nix
    ./sftpgo.nix
    ./syncthing/headless.nix
    # other
    ./postfix.nix
    ./postgresql.nix
  ];

  config = let
    host = config.networking.hostName;
    # services running on this machine
    localServices = with lib; filterAttrs (_: {hosts, ...}: (elem host hosts)) cfg;
  in {
    local.services = with lib; mapAttrs (service: {hosts, ...}: {enable = true;}) localServices;

    local.reverseProxy = {
      localRedirectHost = judgement;
      services = with lib;
        listToAttrs (mapAttrsToList (service: {hosts, ...}: (nameValuePair service {unique = (length hosts) == 1;}))
          localServices);
    };
  };
}
