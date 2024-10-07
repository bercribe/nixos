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
          "192.168.0.1" = ["router.lan"];
          "192.168.0.48" = ["switch.lan"];
          "192.168.0.49" = ["pikvm.lan"];
          "192.168.0.51" = [
            "*.mawz-vault.lan"
            "immich.lan"
          ];
          "192.168.0.54" = [
            "*.mawz-nuc.lan"
            "gitea.lan"
            "healthchecks.lan"
            "miniflux.lan"
            "uptime-kuma.lan"
          ];
        };
      in
        builtins.concatLists (builtins.attrValues (builtins.mapAttrs (answer: domains: (builtins.map (domain: {inherit domain answer;}) domains)) domains));
    };
  };
  networking.firewall.allowedUDPPorts = [53];

  networking.firewall.allowedTCPPorts = [80];
  services.caddy = {
    enable = true;
    virtualHosts."http://adguardhome.${config.networking.hostName}.lan".extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';
  };

  # use local DNS
  networking.networkmanager.insertNameservers = ["127.0.0.1"];
}
