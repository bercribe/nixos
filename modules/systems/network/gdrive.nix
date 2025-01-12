{
  self,
  pkgs,
  config,
  ...
}: {
  imports = [
    (self + /modules/clients/rclone.nix)
  ];

  environment.systemPackages = [pkgs.rclone];
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
}
