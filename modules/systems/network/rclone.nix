{
  pkgs,
  config,
  lib,
  local,
  ...
}: let
  cfg = config.local.rclone;
in {
  options.local.rclone.enable = lib.mkEnableOption "rclone mounts";

  config = lib.mkIf cfg.enable {
    # https://rclone.org/drive/
    sops.secrets."google/rclone/clientId" = {};
    sops.secrets."google/rclone/clientSecret" = {};
    sops.secrets."google/rclone/token/access_token" = {};
    sops.secrets."google/rclone/token/refresh_token" = {};
    sops.secrets."google/rclone/token/expiry" = {};
    sops.templates."rclone.conf" = {
      owner = "mawz";
      path = "/home/mawz/.config/rclone/rclone.conf";
      content = ''
        [echoes]
        type = sftp
        host = echoes.${local.secrets.personal-domain}
        port = 2022
        user = mawz
        key_file = ${config.sops.secrets.ssh.path}

        [gdrive]
        type = drive
        client_id = ${config.sops.placeholder."google/rclone/clientId"}
        client_secret = ${config.sops.placeholder."google/rclone/clientSecret"}
        scope = drive
        token = {"access_token":"${config.sops.placeholder."google/rclone/token/access_token"}","token_type":"Bearer","refresh_token":"${config.sops.placeholder."google/rclone/token/refresh_token"}","expiry":"${config.sops.placeholder."google/rclone/token/expiry"}"}
        team_drive =
      '';
    };
    environment.systemPackages = [pkgs.rclone];

    fileSystems."/mnt/echoes" = {
      device = "echoes:";
      fsType = "rclone";
      options = [
        "nodev"
        "nofail"
        "allow_other"
        "args2env"
        "config=${config.sops.templates."rclone.conf".path}"
      ];
    };

    fileSystems."/mnt/gdrive" = {
      device = "gdrive:";
      fsType = "rclone";
      options = [
        "nodev"
        "nofail"
        "allow_other"
        "args2env"
        "config=${config.sops.templates."rclone.conf".path}"
      ];
    };
  };
}
