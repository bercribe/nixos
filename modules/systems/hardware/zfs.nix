{
  self,
  config,
  pkgs,
  ...
}: {
  local.services.postfix.enable = true;

  services.zfs.autoScrub.enable = true;

  services.zfs.zed = {
    # this option does not work; will return error
    enableMail = false;
    settings = {
      ZED_DEBUG_LOG = "/tmp/zed.debug.log";
      ZED_EMAIL_ADDR = ["root"];
      ZED_EMAIL_PROG = "${pkgs.postfix}/bin/sendmail";
      ZED_EMAIL_OPTS = "@ADDRESS@";

      ZED_NOTIFY_INTERVAL_SECS = 3600;
      ZED_NOTIFY_VERBOSE = true;

      ZED_USE_ENCLOSURE_LEDS = true;
      ZED_SCRUB_AFTER_RESILVER = true;
    };
  };
}
