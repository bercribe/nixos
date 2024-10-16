{
  self,
  config,
  pkgs,
  ...
}: {
  imports = [
    (self + /modules/sops.nix)
    (self + /modules/clients/local-healthchecks.nix)
  ];

  sops.secrets."ups/observer" = {
    sopsFile = self + /secrets/common.yaml;
  };

  # shutdown machine automatically during power outage
  power.ups = {
    enable = true;
    mode = "netclient";
    upsmon = {
      settings = {
        MINSUPPLIES = 1;
        RUN_AS_USER = "root";
        SHUTDOWNCMD = "${pkgs.systemd}/bin/shutdown now";
      };
      monitor.cyberpower = {
        system = "ups@192.168.0.54";
        type = "secondary";
        user = "observer";
        passwordFile = config.sops.secrets."ups/observer".path;
      };
    };
  };
}
