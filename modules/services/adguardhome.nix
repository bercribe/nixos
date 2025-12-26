{
  config,
  lib,
  local,
  ...
}: let
  cfg = config.local.services.adguardhome;
  port = 29222;

  utils = local.utils;
in {
  options.local.services.adguardhome.enable = lib.mkEnableOption "adguardhome";

  config = lib.mkIf cfg.enable {
    services.adguardhome = {
      enable = true;
      inherit port;
      openFirewall = true;
      settings = {
        http.port = port;
        filters = [
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_1.txt";
            name = "AdGuard DNS filter";
            id = 1;
          }
          {
            enabled = true;
            url = "https://adguardteam.github.io/HostlistsRegistry/assets/filter_2.txt";
            name = "AdAway Default Blocklist";
            id = 2;
          }
        ];
        filtering.rewrites = let
          domainRewrites = with lib;
            concatLists (mapAttrsToList (
                hostname: _: [
                  {
                    domain = "${hostname}.lan";
                    answer = utils.hostDomain hostname;
                  }
                  {
                    domain = "*.${hostname}.lan";
                    answer = utils.hostDomain hostname;
                  }
                ]
              )
              config.local.constants.hosts);
          registryRewrites = with lib;
            mapAttrsToList (_: {
              shortName,
              hosts,
              ...
            }: {
              domain = "${shortName}.lan";
              answer = utils.hostDomain (head hosts);
            }) (filterAttrs (_: {hosts, ...}: (length hosts) == 1) config.local.constants.service-registry);
        in
          domainRewrites ++ registryRewrites;
        user_rules = [
          "@@||fc.yahoo.com^$important"
        ];
      };
    };
    networking.firewall.allowedUDPPorts = [53];

    local.reverseProxy = {
      enable = true;
      services.adguardhome = {
        inherit port;
      };
    };

    # use local DNS
    networking.nameservers = ["127.0.0.1"];
  };
}
