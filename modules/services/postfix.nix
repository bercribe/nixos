{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.local.services.postfix;
in {
  options.local.services.postfix.enable = lib.mkEnableOption "postfix";

  config = lib.mkIf cfg.enable {
    sops.secrets."postfix/sasl_passwd" = {
      owner = config.services.postfix.user;
      sopsFile = self + /secrets/common.yaml;
    };

    # email - mail transfer agent
    services.postfix = {
      enable = true;
      relayHost = "smtp.gmail.com";
      relayPort = 587;
      config = {
        smtp_use_tls = "yes";
        smtp_sasl_auth_enable = "yes";
        smtp_sasl_security_options = "";
        smtp_sasl_password_maps = "texthash:${config.sops.secrets."postfix/sasl_passwd".path}";
        # optional: Forward mails to root (e.g. from cron jobs, smartd)
        # to me privately and to my work email:
        virtual_alias_maps = "inline:{ {root=mawz@hey.com} }";
      };
    };
  };
}
