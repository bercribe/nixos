{
  config,
  lib,
  ...
}: let
  cfg = config.local.services.sftpgo;
  httpPort = 48814;
  sftpPort = 2022;
in {
  options.local.services.sftpgo.enable = lib.mkEnableOption "sftpgo";

  config = lib.mkIf cfg.enable {
    sops.secrets.sftpgo-data-file = {
      owner = config.services.sftpgo.user;
      key = "sftpgo/data-file";
    };

    local.cron.email-healthchecks.enable = true;

    services.sftpgo = {
      enable = true;
      loadDataFile = config.sops.secrets.sftpgo-data-file.path;
      settings = {
        common.defender.enabled = true;
        data_provider.backups_path = "${config.services.sftpgo.dataDir}/storage/backups";
        httpd.bindings = [
          {
            port = httpPort;
          }
        ];
        sftpd = {
          keyboard_interactive_authentication = false;
          password_authentication = false;
          bindings = [
            {
              port = sftpPort;
              address = "0.0.0.0";
            }
          ];
        };
        smtp = {
          host = "localhost";
          port = 25;
          encryption = 0;
          user = "";
          from = "SFTPGo <noreply@sftpgo.lan>";
          templates_path = "${config.services.sftpgo.package}/share/sftpgo/templates";
        };
      };
    };
    networking.firewall.allowedTCPPorts = [sftpPort];

    local.reverseProxy = {
      enable = true;
      services.sftpgo = {
        port = httpPort;
      };
    };
  };
}
