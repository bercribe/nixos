{
  config,
  pkgs,
  ...
}: {
  # https://rclone.org/drive/
  sops.secrets."google/rclone/clientId" = {};
  sops.secrets."google/rclone/clientSecret" = {};
  sops.secrets."google/rclone/token/access_token" = {};
  sops.secrets."google/rclone/token/refresh_token" = {};
  sops.secrets."google/rclone/token/expiry" = {};
  sops.templates."rclone-mnt.conf".content = ''
    [gdrive]
    type = drive
    client_id = ${config.sops.placeholder."google/rclone/clientId"}
    client_secret = ${config.sops.placeholder."google/rclone/clientSecret"}
    scope = drive
    token = {"access_token":"${config.sops.placeholder."google/rclone/token/access_token"}","token_type":"Bearer","refresh_token":"${config.sops.placeholder."google/rclone/token/refresh_token"}","expiry":"${config.sops.placeholder."google/rclone/token/expiry"}"}
    team_drive =
  '';

  environment.systemPackages = [pkgs.rclone];
  fileSystems."/mnt/gdrive" = {
    device = "gdrive:";
    fsType = "rclone";
    options = [
      "nodev"
      "nofail"
      "allow_other"
      "args2env"
      "config=${config.sops.templates."rclone-mnt.conf".path}"
    ];
  };
}
