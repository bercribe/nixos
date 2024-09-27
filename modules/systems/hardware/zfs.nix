{
  self,
  config,
  pkgs,
  ...
}: {
  imports = [
    (self + /modules/sops.nix)
  ];

  sops.secrets.email-notifications = {};

  services.zfs.autoScrub.enable = true;

  services.zfs.zed = {
    # this option does not work; will return error
    enableMail = false;
    settings = {
      ZED_DEBUG_LOG = "/tmp/zed.debug.log";
      ZED_EMAIL_ADDR = ["root"];
      ZED_EMAIL_PROG = "${pkgs.msmtp}/bin/msmtp";
      ZED_EMAIL_OPTS = "@ADDRESS@";

      ZED_NOTIFY_INTERVAL_SECS = 3600;
      ZED_NOTIFY_VERBOSE = true;

      ZED_USE_ENCLOSURE_LEDS = true;
      ZED_SCRUB_AFTER_RESILVER = true;
    };
  };

  # email client - used by zed
  programs.msmtp = {
    enable = true;
    defaults.aliases = "/etc/aliases";
    accounts.default = {
      auth = true;
      tls = true;
      host = "smtp.gmail.com";
      port = 587;
      from = "bercribe.notifications";
      user = "bercribe.notifications";
      passwordeval = "cat ${config.sops.secrets.email-notifications.path}";
    };
  };

  # redirect emails sent to root
  environment.etc = {
    "aliases" = {
      text = ''
        root: mawz@hey.com
      '';
      mode = "0644";
    };
  };
}
