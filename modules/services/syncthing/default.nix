{
  self,
  config,
  lib,
  ...
}: {
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
    # generate with `nix-shell -p syncthing --run "syncthing -generate=myconfig"`
    cert = config.sops.secrets.syncthing-cert.path;
    key = config.sops.secrets.syncthing-key.path;
    settings = {
      devices = {
        "geb" = {id = "Z5BAWSH-SKUWWP7-AIPUJIT-FNB4E3U-4LDOCVV-XGZOBHO-VJ26EAB-XNHEFAF";};
        "heavens-door" = {id = "D2VC45J-2GRDWF4-NAIWZA7-VTRHVCR-FDEZNNG-2P5ERHE-CLPZ6UK-JI3NEQ7";};
        "highway-star" = {id = "4OCFYCK-E7KDT4V-7HC7TGK-DZX7GDN-PCE4SR2-UEMNJWH-6Z6XR47-6YU7SAX";};
        "mr-president" = {id = "XX5DKCN-4OTCVAB-2QWFVBN-NVIK24H-AENGONB-FQ67OPV-GITYMJY-55S6AAV";};
        "super-fly" = {id = "FFCN6AI-P6CNSVI-YD2ITV2-4FT6YGG-L2WI5AS-NVKLI2T-HIBRJRO-7W5QSQW";};
      };
      folders = let
        versioning = {
          type = "staggered";
          params = {
            cleanInterval = "3600";
            maxAge = "2592000"; # 30 days
          };
        };
      in {
        personal-cloud = {
          enable = lib.mkDefault false;
          path = lib.mkDefault "/home/mawz/personal-cloud";
          devices = ["geb" "heavens-door" "highway-star" "mr-president" "super-fly"];
          inherit versioning;
        };
        projects = {
          enable = lib.mkDefault false;
          path = lib.mkDefault "/home/mawz/projects";
          devices = ["heavens-door" "highway-star" "mr-president" "super-fly"];
          inherit versioning;
        };
        libraries = {
          enable = lib.mkDefault false;
          path = lib.mkDefault "/home/mawz/libraries";
          devices = ["heavens-door" "mr-president" "super-fly"];
          inherit versioning;
        };
        geb = {
          enable = lib.mkDefault false;
          path = lib.mkDefault "/home/mawz/geb";
          devices = ["geb" "super-fly"];
          inherit versioning;
        };
      };
    };
  };
}
