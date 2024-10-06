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
        vaultDomains = [
          "*.mawz-vault.lan"
          "gitea.lan"
          "healthchecks.lan"
          "immich.lan"
          "miniflux.lan"
          "uptime-kuma.lan"
        ];
      in
        [
          {
            domain = "router.lan";
            answer = "192.168.0.1";
          }
          {
            domain = "switch.lan";
            answer = "192.168.0.48";
          }
          {
            domain = "pikvm.lan";
            answer = "192.168.0.49";
          }
          {
            domain = "*.mawz-nuc.lan";
            answer = "192.168.0.54";
          }
        ]
        ++ builtins.map (domain: {
          inherit domain;
          answer = "192.168.0.51";
        })
        vaultDomains;
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
