{
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
        devices = with lib;
          config.local.constants.hosts
          |> filterAttrs (_: {syncthingId, ...}: !(isNull syncthingId))
          |> mapAttrs (_: {syncthingId, ...}: {id = syncthingId;});
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
            devices = ["geb" "heavens-door" "highway-star" "sethan" "super-fly" "whitesnake"];
            inherit versioning;
            ignorePatterns = [".git"];
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
          media = {
            enable = lib.mkDefault false;
            path = lib.mkDefault "/home/mawz/media";
            devices = ["heavens-door" "highway-star" "sethan" "super-fly" "whitesnake"];
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
          whitesnake = {
            enable = lib.mkDefault false;
            path = lib.mkDefault "/home/mawz/whitesnake";
            devices = ["whitesnake" "super-fly"];
            inherit versioning;
          };
        };
      };
    };
  };
}
