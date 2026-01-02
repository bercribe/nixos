{
  config,
  lib,
  local,
  ...
}: let
  cfg = config.local.services.frigate;
  utils = local.utils;

  dataDir = "/services/frigate";

  hostAddress = "10.231.136.1";
  containerAddress = "10.231.136.2";
  localInterface = "enp89s0";
  camInterface = "enp0s20f0u1u1";

  coralGid = 999;

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
  options.local.services.frigate.enable = lib.mkEnableOption "frigate";

  config = lib.mkIf cfg.enable {
    local.healthchecks-secret.enable = true;

    sops.secrets."frigate/rtsp/user" = {};
    sops.secrets."frigate/rtsp/pass" = {};
    sops.secrets."mosquitto/frigate" = {};
    sops.templates."frigate.env".content = ''
      FRIGATE_RTSP_USER=${config.sops.placeholder."frigate/rtsp/user"}
      FRIGATE_RTSP_PASSWORD=${config.sops.placeholder."frigate/rtsp/pass"}
      FRIGATE_MQTT_PASSWORD=${config.sops.placeholder."mosquitto/frigate"}
    '';

    # camera subnet
    networking.interfaces.${camInterface} = {
      ipv4.addresses = [
        {
          address = "10.0.40.1";
          prefixLength = 24;
        }
      ];
    };

    # coral TPU
    hardware.coral.usb.enable = true;
    users.groups.coral.gid = coralGid;

    # needed for network connectivity from the container to external addresses
    networking.nat = {
      enable = true;
      internalInterfaces = ["ve-frigate"];
      externalInterface = localInterface;
      # Lazy IPv6 connectivity for the container
      enableIPv6 = true;
    };
    # needed to reach mosquitto instance
    networking.firewall.trustedInterfaces = ["ve-frigate"];

    containers.frigate = let
      systemStateVersion = config.system.stateVersion;
      envPath = config.sops.templates."frigate.env".path;
    in {
      autoStart = true;

      privateNetwork = true;
      inherit hostAddress;
      localAddress = containerAddress;
      hostAddress6 = "fc00::1";
      localAddress6 = "fc00::2";

      bindMounts = {
        "/var/lib/frigate" = {
          hostPath = dataDir;
          isReadOnly = false;
        };
        "${envPath}".isReadOnly = true;
        "${config.sops.secrets."healthchecks/local/ping-key".path}".isReadOnly = true;
        # intel hardware accel
        "/dev/dri/renderD128".isReadOnly = false;
        # coral TPU device
        "/dev/bus/usb".isReadOnly = false;
      };

      allowedDevices = [
        # intel hardware accel
        {
          modifier = "rw";
          node = "/dev/dri/renderD128";
        }
        # coral TPU
        {
          modifier = "rw";
          node = "char-usb_device";
        }
      ];

      # GPU stats
      additionalCapabilities = ["CAP_PERFMON"];
      extraFlags = ["--system-call-filter=perf_event_open"];

      config = {
        config,
        pkgs,
        lib,
        ...
      }: {
        # intel hardware accel
        hardware.graphics = {
          enable = true;
          extraPackages = [pkgs.intel-media-driver];
        };

        # coral TPU
        hardware.coral.usb.enable = true;
        users.groups.coral.gid = coralGid;

        services.frigate = {
          enable = true;
          hostname = "localhost";
          vaapiDriver = "iHD";
          preCheckConfig = ''
            export FRIGATE_RTSP_USER=rtsp-user
            export FRIGATE_RTSP_PASSWORD=rtsp-pass
            export FRIGATE_MQTT_PASSWORD=mqtt-pass
          '';
          settings = let
            userPass = "{FRIGATE_RTSP_USER}:{FRIGATE_RTSP_PASSWORD}";
            frigatePath = camera: subtype: (cameraPath {inherit userPass camera subtype;});
          in {
            mqtt = {
              enabled = true;
              host = hostAddress;
              user = "frigate";
              password = "{FRIGATE_MQTT_PASSWORD}";
            };
            ffmpeg.hwaccel_args = "preset-vaapi";
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
        systemd.services.frigate.serviceConfig.EnvironmentFile = envPath;

        services.go2rtc = {
          enable = true;
          settings.streams = go2rtcStreams "\${FRIGATE_RTSP_USER}:\${FRIGATE_RTSP_PASSWORD}";
        };
        systemd.services.go2rtc.serviceConfig.EnvironmentFile = envPath;

        # health checks
        systemd.timers.camera-heartbeats = {
          wantedBy = ["timers.target"];
          timerConfig = {
            OnBootSec = "5m";
            OnUnitActiveSec = "5m";
            Unit = "camera-heartbeats.service";
          };
        };
        systemd.services.camera-heartbeats = {
          serviceConfig = {
            Type = "oneshot";
            User = "root";
          };
          script = let
            curl = lib.getExe pkgs.curl;
            cameraChecks = pkgs.writeShellScript "camera-checks" (with lib;
              cameras
              |> mapAttrsToList (camera: {address}: "echo \"${camera}:\"; ${curl} -v rtsp://${address}:554\n")
              |> concatStrings);
          in ''
            ${utils.writeHealthchecksCombinedScript {slug = "camera-heartbeats";} cameraChecks}
          '';
        };

        networking = {
          firewall.allowedTCPPorts = [80];

          # Use systemd-resolved inside the container
          # Workaround for bug https://github.com/NixOS/nixpkgs/issues/162686
          useHostResolvConf = lib.mkForce false;
        };

        services.resolved.enable = true;

        system.stateVersion = systemStateVersion;
      };
    };

    local.reverseProxy = {
      enable = true;
      services.frigate = {
        address = containerAddress;
        port = 80;
      };
    };
  };
}
