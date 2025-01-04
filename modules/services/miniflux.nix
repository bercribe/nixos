{
  self,
  config,
  pkgs,
  ...
}: let
  port = 9044;
  hostUrl = "${config.networking.hostName}.mawz.dev";
  url = "miniflux.${hostUrl}";
in {
  imports = [
    (self + /modules/sops.nix)
  ];

  sops.secrets.miniflux-admin = {};

  services.miniflux = {
    enable = true;
    config = {
      PORT = toString port;
      BASE_URL = "https://${url}/";
      FETCH_YOUTUBE_WATCH_TIME = 1;
    };
    adminCredentialsFile = config.sops.secrets.miniflux-admin.path;
  };
  services.postgresql.dataDir = "/services/postgres/${config.services.postgresql.package.psqlSchema}";

  networking.firewall.allowedTCPPorts = [80 443 port];
  services.caddy = {
    enable = true;
    virtualHosts."http://miniflux.lan".extraConfig = ''
      redir https://${url}{uri} permanent
    '';
    virtualHosts."${url}".extraConfig = let
      certDir = config.security.acme.certs."${hostUrl}".directory;
    in ''
      reverse_proxy localhost:${toString port}
      tls ${certDir}/cert.pem ${certDir}/key.pem
    '';
  };
}
