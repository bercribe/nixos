{
  self,
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.local.services.uptime-kuma;
  port = 13114;
  dataDir = "/services/uptime-kuma/";
in {
  options.local.services.uptime-kuma.enable = lib.mkEnableOption "uptime-kuma";

  config = lib.mkIf cfg.enable {
    local.services.postfix.enable = true;

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
      services.uptime-kuma = {
        inherit port;
      };
    };
  };
}
