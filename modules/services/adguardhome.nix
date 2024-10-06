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
        vaultIp = "192.168.0.51";
      in [
        {
          domain = "adguardhome.lan";
          answer = vaultIp;
        }
        {
          domain = "gitea.lan";
          answer = vaultIp;
        }
        {
          domain = "healthchecks.lan";
          answer = vaultIp;
        }
        {
          domain = "immich.lan";
          answer = vaultIp;
        }
        {
          domain = "miniflux.lan";
          answer = vaultIp;
        }
        {
          domain = "uptime-kuma.lan";
          answer = vaultIp;
        }
      ];
    };
  };
  networking.firewall.allowedUDPPorts = [53];

  # use local DNS
  networking.networkmanager.insertNameservers = ["127.0.0.1"];
}
