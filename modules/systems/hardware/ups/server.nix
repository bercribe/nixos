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

  sops.secrets."ups/admin" = {};
  sops.secrets."ups/observer" = {
    sopsFile = self + /secrets/common.yaml;
  };
  sops.secrets."ups/monuser" = {};

  power.ups = {
    enable = true;
    mode = "netserver";
    ups.ups = {
      description = "CyberPower 1500PFCLCD";
      driver = "usbhid-ups";
      port = "auto";
      directives = [
        "override.battery.charge.low = 50"
        "override.battery.runtime.low = 300"
        "ignorelb"
      ];
    };
    upsd.listen = [
      {
        address = "0.0.0.0";
        port = 3493;
      }
    ];
    openFirewall = true;
    users = {
      admin = {
        upsmon = "primary";
        passwordFile = config.sops.secrets."ups/admin".path;
      };
      observer = {
        upsmon = "secondary";
        passwordFile = config.sops.secrets."ups/observer".path;
      };
      # only used for synology device
      monuser = {
        upsmon = "secondary";
        passwordFile = config.sops.secrets."ups/monuser".path;
      };
    };
    upsmon = {
      monitor.cyberpower = {
        system = "ups";
        type = "primary";
        user = "admin";
        passwordFile = config.sops.secrets."ups/admin".path;
      };
      settings = {
        MINSUPPLIES = 1;
        RUN_AS_USER = "root";
        SHUTDOWNCMD = "systemctl restart upsd";
      };
    };
  };

  systemd.timers.ups-monitor = {
    wantedBy = ["timers.target"];
    timerConfig = {
      OnBootSec = "5m";
      OnUnitActiveSec = "5m";
      Unit = "ups-monitor.service";
    };
  };
  systemd.services.ups-monitor = {
    serviceConfig = {
      Type = "oneshot";
      User = "root";
    };
    script = ''
      status=$(${pkgs.nut}/bin/upsc ups ups.status 2>&1) || true
      runtime=$(${pkgs.nut}/bin/upsc ups battery.runtime 2>&1) || true

      if [[ "$runtime" =~ ^[0-9]+$ ]] && [ "$runtime" -ge 1000 ]; then
        slug="ups-runtime"
        if [[ "$status" == "OL"* ]]; then
          ${pkgs.wol}/bin/wol 74:56:3c:e4:75:32 # mawz-vault
          ${pkgs.wol}/bin/wol 00:11:32:ea:02:ab # mawz-nas
          ${pkgs.wol}/bin/wol 00:11:32:ea:02:ac # mawz-nas
        fi
      else
        slug="ups-runtime/fail"
      fi

      pingKey="$(cat ${config.sops.secrets."healthchecks/local/ping-key".path})"
      ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused --data-raw "UPS runtime remaining: $runtime seconds" "http://healthchecks.lan/ping/$pingKey/$slug"
    '';
  };
}