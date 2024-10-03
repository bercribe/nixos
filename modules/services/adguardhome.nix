{config, ...}: let
  port = 29222;
in {
  services.adguardhome = {
    enable = true;
    inherit port;
    openFirewall = true;
    settings = {
      http.port = port;
      filtering.rewrites = [
        {
          domain = "uptime-kuma.lan";
          answer = "192.168.0.51";
        }
      ];
    };
  };
  networking.firewall.allowedUDPPorts = [53];

  # use local DNS
  networking.networkmanager.insertNameservers = ["127.0.0.1"];
}
