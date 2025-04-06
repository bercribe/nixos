{
  config,
  self,
  ...
}: {
  imports = [
    ./default.nix
    (self + /modules/cron/syncthing-healthchecks.nix)
  ];

  local.reverseProxy = {
    enable = true;
    services.syncthing = {
      port = 8384;
      unique = false;
      httpsBackend = true;
    };
  };
}
