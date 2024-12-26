{
  self,
  config,
  pkgs,
  ...
}: let
  port = 9044;
in {
  imports = [
    (self + /modules/sops.nix)
  ];

  sops.secrets.miniflux-admin = {};

  services.miniflux = {
    enable = true;
    config = {
      PORT = toString port;
      BASE_URL = "http://miniflux.lan/";
      FETCH_YOUTUBE_WATCH_TIME = 1;
    };
    adminCredentialsFile = config.sops.secrets.miniflux-admin.path;
  };
  services.postgresql.dataDir = "/services/postgres/${config.services.postgresql.package.psqlSchema}";

  networking.firewall.allowedTCPPorts = [80 port];
  services.caddy = {
    enable = true;
    virtualHosts."http://miniflux.lan".extraConfig = ''
      reverse_proxy localhost:${toString port}
    '';
  };
}
