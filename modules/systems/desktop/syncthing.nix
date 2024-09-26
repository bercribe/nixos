{
  config,
  lib,
  ...
}: {
  # Syncthing folders. Access UI at: http://127.0.0.1:8384/
  services.syncthing = {
    enable = true;
    user = "mawz";
    dataDir = "/home/mawz/Documents"; # Default folder for new synced folders
    configDir = "/home/mawz/Documents/.config/syncthing"; # Folder for Syncthing's settings and keys
    overrideDevices = true; # overrides any devices added or deleted through the WebUI
    overrideFolders = true; # overrides any folders added or deleted through the WebUI
    settings = {
      devices = {
        "mawz-nas" = {id = "XX5DKCN-4OTCVAB-2QWFVBN-NVIK24H-AENGONB-FQ67OPV-GITYMJY-55S6AAV";};
        "mawz-hue" = {id = "D2VC45J-2GRDWF4-NAIWZA7-VTRHVCR-FDEZNNG-2P5ERHE-CLPZ6UK-JI3NEQ7";};
        "mawz-hue-win" = {id = "UCHJJO7-WXOENUZ-SBOV5NO-LSRAGOJ-IWGNSCY-SETUCQF-5PZTPLZ-VXWYFQG";};
        "mawz-fw" = {id = "EASFCDW-AI3FKGE-RECE37P-ZUN7WOZ-4YWFU2K-CLTJ2GG-YIBZJCW-D3EBNQN";};
        "mawz-galaxy" = {id = "Z5BAWSH-SKUWWP7-AIPUJIT-FNB4E3U-4LDOCVV-XGZOBHO-VJ26EAB-XNHEFAF";};
      };
      folders = {
        personal-cloud = {
          enable = lib.mkDefault false;
          path = lib.mkDefault "/home/mawz/personal-cloud";
          devices = ["mawz-nas" "mawz-hue" "mawz-hue-win" "mawz-fw" "mawz-galaxy"];
          versioning = {
            type = "staggered";
            params = {
              cleanInterval = "3600";
              maxAge = "31536000";
            };
          };
        };
        projects = {
          enable = lib.mkDefault false;
          path = lib.mkDefault "/home/mawz/projects";
          devices = ["mawz-nas" "mawz-hue" "mawz-hue-win" "mawz-fw"];
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
          devices = ["mawz-nas" "mawz-hue" "mawz-hue-win"];
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
