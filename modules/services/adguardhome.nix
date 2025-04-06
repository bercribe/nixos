{config, ...}: let
  port = 29222;
in {
  services.adguardhome = {
    enable = true;
    inherit port;
    openFirewall = true;
    settings = {
      http.port = port;
      filtering.rewrites = let
        domains = {
          "hierophant-green.mawz.dev" = ["hierophant-green.lan"];
          "hermit-purple.mawz.dev" = ["hermit-purple.lan"];
          "lovers.mawz.dev" = ["lovers.lan"];
          "moody-blues.mawz.dev" = ["moody-blues.lan"];
          "mr-president.mawz.dev" = ["mr-president.lan"];
          "super-fly.mawz.dev" = [
            "super-fly.lan"
            "*.super-fly.lan"
            "immich.lan"
            "jellyfin.lan"
            "paisa.lan"
          ];
          "judgement.mawz.dev" = [
            "judgement.lan"
            "*.judgement.lan"
            "frigate.lan"
            "gitea.lan"
            "hass.lan"
            "healthchecks.lan"
            "miniflux.lan"
            "ukuma.lan"
          ];
        };
      in
        builtins.concatLists (builtins.attrValues (builtins.mapAttrs (answer: domains: (builtins.map (domain: {inherit domain answer;}) domains)) domains));
    };
  };
  networking.firewall.allowedUDPPorts = [53];

  local.reverseProxy = {
    enable = true;
    services.aghome = {
      inherit port;
      unique = false;
    };
  };

  # use local DNS
  networking.nameservers = ["127.0.0.1"];
}
