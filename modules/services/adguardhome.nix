{
  config,
  lib,
  ...
}: let
  cfg = config.local.services.adguardhome;
  port = 29222;
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
          domains = {
            "hierophant-green.mawz.dev" = ["hierophant-green.lan"];
            "hermit-purple.mawz.dev" = ["hermit-purple.lan"];
            "judgement.mawz.dev" = [
              "judgement.lan"
              "*.judgement.lan"
            ];
            "lovers.mawz.dev" = ["lovers.lan"];
            "moody-blues.mawz.dev" = [
              "moody-blues.lan"
              "*.moody-blues.lan"
            ];
            "mr-president.mawz.dev" = ["mr-president.lan"];
            "super-fly.mawz.dev" = [
              "super-fly.lan"
              "*.super-fly.lan"
            ];
          };
          domainRewrites = with lib; concatLists (attrValues (mapAttrs (answer: domains: (map (domain: {inherit domain answer;}) domains)) domains));
          registryRewrites = with lib;
            mapAttrsToList (_: {
              shortName,
              hosts,
              ...
            }: {
              domain = "${shortName}.lan";
              answer = "${head hosts}.mawz.dev";
            }) (filterAttrs (_: {hosts, ...}: (length hosts) == 1) config.local.service-registry);
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
