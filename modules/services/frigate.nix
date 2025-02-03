{
  self,
  config,
  pkgs,
  lib,
  ...
}: let
  dataDir = "/services/frigate";
  port = 18841;
  hostname = "localhost";
  interface = "enp3s0";

  cameras = {
    mawz_office = {
      address = "10.0.40.10";
    };
    front_porch = {
      address = "10.0.40.11";
    };
  };
  cameraPath = params: "rtsp://${params.userPass}@${cameras."${params.camera}".address}:554/cam/realmonitor?channel=1&subtype=${params.subtype}";
  go2rtcStreams = userPass:
    lib.mapAttrs (camera: value:
      cameraPath {
        inherit camera userPass;
        subtype = "0";
      })
    cameras;
in {
  sops.secrets."frigate/env" = {};

  # camera subnet
  networking.interfaces.${interface} = {
    ipv4.addresses = [
      {
        address = "10.0.40.1";
        prefixLength = 24;
      }
    ];
  };

  # hardware accel
  hardware.graphics = {
    enable = true;
    # TODO: enable?
    # extraPackages = [pkgs.intel-media-driver];
  };

  # coral TPU
  hardware.coral.usb.enable = true;

  services.frigate = {
    enable = true;
    inherit hostname;
    settings = let
      userPass = "{FRIGATE_RTSP_USER}:{FRIGATE_RTSP_PASSWORD}";
      frigatePath = camera: subtype: (cameraPath {inherit userPass camera subtype;});
    in {
      mqtt = {
        enabled = true;
        host = "192.168.0.43";
        user = "{FRIGATE_MQTT_USER}";
        password = "{FRIGATE_MQTT_PASSWORD}";
      };
      # TODO: enable
      # ffmpeg.hwaccel_args = "preset-vaapi";
      detectors.coral = {
        type = "edgetpu";
        device = "usb";
      };
      objects.track = ["person" "cat" "dog"];
      cameras =
        lib.mapAttrs (camera: value: {
          enabled = true;
          ffmpeg = {
            inputs = [
              {
                path = frigatePath "${camera}" "1";
                roles = ["detect"];
              }
              {
                path = frigatePath "${camera}" "0";
                roles = ["record"];
              }
            ];
          };
          detect = {
            enabled = true;
            width = 704;
            height = 480;
          };
          record.enabled = true;
          snapshots.enabled = true;
        })
        cameras;
      go2rtc.streams = go2rtcStreams userPass;
    };
  };
  systemd.services.frigate.serviceConfig.EnvironmentFile = config.sops.secrets."frigate/env".path;

  services.go2rtc = {
    enable = true;
    settings.streams = go2rtcStreams "\${FRIGATE_RTSP_USER}:\${FRIGATE_RTSP_PASSWORD}";
  };
  systemd.services.go2rtc.serviceConfig.EnvironmentFile = config.sops.secrets."frigate/env".path;

  # override data directory
  systemd.services.frigate.serviceConfig.BindPaths = "${dataDir}:/var/lib/frigate";
  systemd.services.nginx.serviceConfig.BindPaths = "${dataDir}:/var/lib/frigate";

  # map caddy to nginx
  services.nginx.virtualHosts."${hostname}".listen = [
    {
      addr = "127.0.0.1";
      inherit port;
    }
  ];
  local.reverseProxy = {
    enable = true;
    services.frigate = {
      inherit port;
    };
  };
}
