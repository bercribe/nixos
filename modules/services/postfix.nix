{
  config,
  lib,
  local,
  secrets,
  ...
}: let
  cfg = config.local.services.postfix;
in {
  options.local.services.postfix.enable = lib.mkEnableOption "postfix";

  config = lib.mkIf cfg.enable {
    sops.secrets."postfix/sasl_passwd" = {
      owner = config.services.postfix.user;
      sopsFile = secrets + /sops/common.yaml;
    };

    # email - mail transfer agent
    services.postfix = {
      enable = true;
      settings.main = {
        relayhost = [
          "[smtp.gmail.com]:587"
        ];
        message_size_limit = 52428800;
        mailbox_size_limit = 104857600;
        smtp_use_tls = "yes";
        smtp_sasl_auth_enable = "yes";
        smtp_sasl_security_options = "";
        smtp_sasl_password_maps = "texthash:${config.sops.secrets."postfix/sasl_passwd".path}";
        # Forward mails to root (e.g. from cron jobs, smartd) to me
        virtual_alias_maps = "inline:{ {root=${local.secrets.email}} }";
      };
    };
  };
}
