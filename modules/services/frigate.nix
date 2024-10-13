{
  self,
  config,
  pkgs,
  lib,
  ...
}: let
  interface = "enp6s0";
  # TODO: force all data here
  dataDir = "/services/frigate";
  configFile = "${dataDir}/config.yaml";
in {
  imports = [
    (self + /modules/sops.nix)
  ];

  sops.secrets."frigate/mqtt" = {
    sopsFile = self + /secrets/nvr.yaml;
  };
  sops.secrets."frigate/rtsp" = {
    sopsFile = self + /secrets/nvr.yaml;
  };

  # camera subnet
  networking.interfaces.${interface} = {
    ipv4.addresses = [
      {
        address = "10.0.40.2";
        prefixLength = 24;
      }
    ];
  };

  services.frigate = {
    enable = true;
    # to fix https://github.com/NixOS/nixpkgs/issues/325228
    package = pkgs.unstable.frigate;
    hostname = "frigate.lan";
    settings = let
      rtspUser = "admin";
      mawzOfficePath = "rtsp://${rtspUser}:${config.sops.placeholder."frigate/rtsp"}@10.0.40.10:554/cam/realmonitor?channel=1&subtype=1";
      frontPorchPath = "rtsp://${rtspUser}:${config.sops.placeholder."frigate/rtsp"}@10.0.40.11:554/cam/realmonitor?channel=1&subtype=1";
    in {
      database.path = "${dataDir}/frigate.db";
      mqtt = {
        enabled = true;
        host = "192.168.0.43";
        user = "hass";
        password = config.sops.placeholder."frigate/mqtt";
      };
      # detectors.coral = {
      #   type = "edgetpu";
      #   device = "usb";
      # };
      cameras = {
        mawz_office = {
          enabled = true;
          ffmpeg = {
            inputs = [
              {
                path = mawzOfficePath;
                roles = ["detect"];
              }
              {
                path = mawzOfficePath;
                roles = ["record"];
              }
            ];
            # hwaccel_args = "preset-vaapi";
          };
          detect = {
            enabled = true;
            width = 704;
            height = 480;
          };
          record.enabled = true;
          snapshots.enabled = true;
        };
        front_porch = {
          enabled = true;
          ffmpeg = {
            inputs = [
              {
                path = frontPorchPath;
                roles = ["detect"];
              }
              {
                path = frontPorchPath;
                roles = ["record"];
              }
            ];
            # hwaccel_args = "preset-vaapi";
          };
          detect = {
            enabled = true;
            width = 704;
            height = 480;
          };
          record.enabled = true;
          snapshots.enabled = true;
        };
      };
      go2rtc.streams = {
        mawz_office = [mawzOfficePath];
        front_porch = [frontPorchPath];
      };
    };
  };

  sops.templates.frigate-config = let
    filteredConfig = lib.converge (lib.filterAttrsRecursive (_: v: ! lib.elem v [null])) config.services.frigate.settings;
  in {
    content = lib.generators.toJSON {} filteredConfig;
  };
  systemd.services.frigate = {
    environment.CONFIG_FILE = lib.mkForce configFile;
    restartTriggers = [configFile];
  };

  # there is no builtin YAML generator: https://github.com/NixOS/nix/issues/4910
  # TODO: try to use frigate supported env vars
  systemd.services.frigate-config-generator = {
    script = ''
      ${pkgs.yq-go}/bin/yq -P < ${config.sops.templates.frigate-config.path} > "${configFile}"
      chown frigate:frigate "${configFile}"
    '';
    wantedBy = ["frigate.service"];
    serviceConfig = {
      User = "root";
    };
  };
}
