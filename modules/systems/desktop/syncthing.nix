{
  self,
  config,
  lib,
  ...
}: {
  imports = [
    (self + /modules/sops.nix)
  ];

  sops.secrets = {
    syncthing-cert = {
      owner = "mawz";
      key = "${config.networking.hostName}/syncthing/cert";
    };
    syncthing-key = {
      owner = "mawz";
      key = "${config.networking.hostName}/syncthing/key";
    };
  };

  # Syncthing folders. Access UI at: http://127.0.0.1:8384/
  services.syncthing = {
    enable = true;
    user = "mawz";
    openDefaultPorts = true;
    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI
    cert = config.sops.secrets.syncthing-cert.path;
    key = config.sops.secrets.syncthing-key.path;
    settings = {
      devices = {
        "mawz-nas" = {id = "XX5DKCN-4OTCVAB-2QWFVBN-NVIK24H-AENGONB-FQ67OPV-GITYMJY-55S6AAV";};
        "mawz-hue" = {id = "D2VC45J-2GRDWF4-NAIWZA7-VTRHVCR-FDEZNNG-2P5ERHE-CLPZ6UK-JI3NEQ7";};
        "highway-star" = {id = "4OCFYCK-E7KDT4V-7HC7TGK-DZX7GDN-PCE4SR2-UEMNJWH-6Z6XR47-6YU7SAX";};
        "mawz-galaxy" = {id = "Z5BAWSH-SKUWWP7-AIPUJIT-FNB4E3U-4LDOCVV-XGZOBHO-VJ26EAB-XNHEFAF";};
      };
      folders = {
        personal-cloud = {
          enable = lib.mkDefault false;
          path = lib.mkDefault "/home/mawz/personal-cloud";
          devices = ["mawz-nas" "mawz-hue" "highway-star" "mawz-galaxy"];
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "2592000";
            };
          };
        };
        projects = {
          enable = lib.mkDefault false;
          path = lib.mkDefault "/home/mawz/projects";
          devices = ["mawz-nas" "mawz-hue" "highway-star"];
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "2592000";
            };
          };
        };
        libraries = {
          enable = lib.mkDefault false;
          path = lib.mkDefault "/home/mawz/libraries";
          devices = ["mawz-nas" "mawz-hue"];
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "2592000";
            };
          };
        };
      };
    };
  };
}
