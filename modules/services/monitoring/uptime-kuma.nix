{
  self,
  config,
  pkgs,
  lib,
  ...
}: let
  port = 13114;
  dataDir = "/services/uptime-kuma/";
in {
  imports = [
    (self + /modules/services/postfix.nix)
  ];

  services.uptime-kuma = {
    enable = true;
    settings = {
      HOST = "0.0.0.0";
      PORT = toString port;
      DATA_DIR = lib.mkForce dataDir;
    };
  };
  systemd.services.uptime-kuma.serviceConfig.ReadWritePaths = dataDir;

  local.reverseProxy = {
    enable = true;
    services.ukuma = {
      inherit port;
    };
  };
}
