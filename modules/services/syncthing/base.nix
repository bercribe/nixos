{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.local.services.syncthing-base;
in {
  options.local.services.syncthing-base.enable = lib.mkEnableOption "syncthing";

  config = lib.mkIf cfg.enable {
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
          "heavens-door" = {id = "HK3YODK-63EFXRW-77XQ2PK-ZB5A35F-6BSAZ6S-J76VARS-KV6HJSN-D7KR4AB";};
          "highway-star" = {id = "EEM5E4H-7TFYA5Y-BY37H4D-25LOQIS-M5ETY2C-JSVJHOL-4O67NI3-CPZQ4AE";};
          "mr-president" = {id = "XX5DKCN-4OTCVAB-2QWFVBN-NVIK24H-AENGONB-FQ67OPV-GITYMJY-55S6AAV";};
          "sethan" = {id = "HXAAIQL-OXKK5KA-YCD6KGU-RBXLLM2-XIDKKVG-GA6PCSZ-C4MZHVK-2H7HNAO";};
          "super-fly" = {id = "QL7YLXY-WKBMRND-BKQB6KN-Q4QI2MT-Z4RJXUS-JF7HJGE-PZ7D7Y2-B5RGJAV";};
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
            devices = ["geb" "heavens-door" "highway-star" "sethan" "super-fly"];
            inherit versioning;
          };
          projects = {
            enable = lib.mkDefault false;
            path = lib.mkDefault "/home/mawz/projects";
            devices = ["heavens-door" "highway-star" "super-fly"];
            inherit versioning;
          };
          libraries = {
            enable = lib.mkDefault false;
            path = lib.mkDefault "/home/mawz/libraries";
            devices = ["heavens-door" "super-fly"];
            inherit versioning;
          };
          geb = {
            enable = lib.mkDefault false;
            path = lib.mkDefault "/home/mawz/geb";
            devices = ["geb" "super-fly"];
            inherit versioning;
          };
          sethan = {
            enable = lib.mkDefault false;
            path = lib.mkDefault "/home/mawz/sethan";
            devices = ["sethan" "super-fly"];
            inherit versioning;
          };
        };
      };
    };
  };
}
