{
  self,
  config,
  pkgs,
  ...
}: let
  port = 45566;
in {
  imports = [
    (self + /modules/services/postfix.nix)
  ];

  sops.secrets = {
    "healthchecks/local/secret-key" = {owner = config.services.healthchecks.user;};
  };

  services.healthchecks = {
    enable = true;
    listenAddress = "0.0.0.0";
    inherit port;
    dataDir = "/services/healthchecks";
    settings = {
      SECRET_KEY_FILE = config.sops.secrets."healthchecks/local/secret-key".path;
      SITE_ROOT = "http://healthchecks.lan";
      EMAIL_HOST = "localhost";
      EMAIL_PORT = "25";
      EMAIL_USE_TLS = "False";
    };
  };

  networking.firewall.allowedTCPPorts = [80 port];
  services.caddy = {
    enable = true;
    virtualHosts."http://healthchecks.lan".extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';
  };
}
