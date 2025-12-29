{
  config,
  pkgs,
  lib,
  local,
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
        data_provider = {
          backups_path = "${config.services.sftpgo.dataDir}/storage/backups";
          post_login_hook = let
            postLoginHook = pkgs.writeShellScript "sftpgo-login-hook" ''
              user=$(echo "$SFTPGO_LOGIND_USER" | ${lib.getExe pkgs.jq} -r '.username')
              proto=$SFTPGO_LOGIND_PROTOCOL
              ip=$SFTPGO_LOGIND_IP
              message=$(${lib.getExe pkgs.jo} user=$user ip=$ip protocol=$proto)
              ${pkgs.util-linux}/bin/logger -t sftpgo-login "$message"
            '';
          in "${postLoginHook}";
          post_login_scope = 2;
        };
        httpd.bindings = [
          {
            port = httpPort;
            enable_web_admin = false;
            enable_rest_api = false;
            proxy_allowed = "127.0.0.1";
            client_ip_proxy_header = "X-Forwarded-For";
          }
          {
            port = 48815;
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

    systemd.services.sftpgo-login-email-relay = {
      description = "SFTPGo login email notification service";
      after = ["network.target"];
      wantedBy = ["sftpgo.service"];
      serviceConfig = {
        Type = "simple";
        User = "root";
      };
      script = let
        sendEmail = pkgs.writeShellScript "sftpgo-login-email" ''
          logDir="${config.services.sftpgo.dataDir}/logins"
          mkdir -p "$logDir"

          line=$1
          user=$(echo "$line" | ${lib.getExe pkgs.jq} -r '.user')
          proto=$(echo "$line" | ${lib.getExe pkgs.jq} -r '.protocol')
          ip=$(echo "$line" | ${lib.getExe pkgs.jq} -r '.ip')

          ip_file="$logDir/last_ip-$user-$proto"
          last_ip=$(cat $ip_file 2>/dev/null)
          echo "$ip" > $ip_file

          if [ "$ip" != "$last_ip" ]; then
            message="SFTPGo login detected by $user from $ip over $proto"
            (
              echo "From: SFTPGo <noreply@sftpgo.lan>"
              echo "Subject: SFTPGo alert"
              echo "Content-Type: text/html"
              echo
              echo "$message"
            ) | ${pkgs.postfix}/bin/sendmail root
          fi
        '';
      in ''
        journalctl -f -t sftpgo-login -o cat | while read -r line; do
          ${sendEmail} "$line" || true
        done
      '';
    };

    local.reverseProxy = {
      enable = true;
      services.sftpgo = {
        port = httpPort;
      };
    };
  };
}
