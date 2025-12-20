{
  config,
  lib,
  ...
}: let
  cfg = config.local.services.sftpgo;
  port = 48814;
in {
  options.local.services.sftpgo.enable = lib.mkEnableOption "sftpgo";

  config = lib.mkIf cfg.enable {
    services.sftpgo = {
      enable = true;
      settings.httpd.bindings = [
        {
          inherit port;
        }
      ];
    };

    local.reverseProxy = {
      enable = true;
      services.sftpgo = {
        inherit port;
      };
    };
  };
}
