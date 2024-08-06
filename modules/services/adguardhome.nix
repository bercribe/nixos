{config, ...}: let
  port = 29222;
in {
  services.adguardhome = {
    enable = true;
    inherit port;
    openFirewall = true;
    settings = {
      http.port = port;
    };
  };
  networking.firewall.allowedUDPPorts = [53];
}
