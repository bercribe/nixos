{config, ...}: {
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
      [gdrive]
      type = drive
      client_id = ${config.sops.placeholder."google/rclone/clientId"}
      client_secret = ${config.sops.placeholder."google/rclone/clientSecret"}
      scope = drive
      token = {"access_token":"${config.sops.placeholder."google/rclone/token/access_token"}","token_type":"Bearer","refresh_token":"${config.sops.placeholder."google/rclone/token/refresh_token"}","expiry":"${config.sops.placeholder."google/rclone/token/expiry"}"}
      team_drive =
    '';
  };
}
