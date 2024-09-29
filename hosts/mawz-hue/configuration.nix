{
  self,
  config,
  pkgs,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    (self + /modules/systems/desktop)
    (self + /modules/systems/hardware/nvidia.nix)
    (self + /modules/sops.nix)
  ];

  # Config

  # Secrets
  sops.secrets = {
    "ssh/private" = {
      owner = "mawz";
      path = "/home/mawz/.ssh/id_ed25519";
      key = "mawz-hue/ssh/private";
    };
    "mawz-nas/upsd" = {};
  };

  # Bootloader.
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/nvme1n1";
  boot.loader.grub.useOSProber = true;

  networking.hostName = "mawz-hue"; # Define your hostname.

  # User env
  home-manager.users.mawz = import ./home.nix;
  users.users.mawz.packages = [
    (import (self + /modules/scripts/asw.nix) {inherit pkgs;})
  ];

  # Services

  # Syncthing folders. Access UI at: http://127.0.0.1:8384/
  services.syncthing.settings.folders = {
    personal-cloud = {
      enable = true;
      path = "/mnt/distant-disk/personal cloud";
    };
    projects = {
      enable = true;
      path = "/mnt/distant-disk/projects";
    };
    libraries = {
      enable = true;
      path = "/mnt/distant-disk/Libraries";
    };
    mawz-hue = {
      path = "/backups";
      devices = ["mawz-nas"];
    };
  };

  # shutdown machine automatically during power outage
  # machine IP needs to be allowed in the synology control pannel
  # look for "Permitted Synology NAS Devices"
  power.ups = let
    notifyCmd = pkgs.writeShellScript "notify-cmd" ''
      ${pkgs.util-linux}/bin/logger -t notify-cmd "$@"
    '';
  in {
    enable = true;
    mode = "netclient";
    upsmon = {
      enable = true;
      settings = {
        NOTIFYCMD = "${notifyCmd}";
        NOTIFYFLAG = [
          ["ONLINE" "SYSLOG+WALL+EXEC"]
          ["ONBATT" "SYSLOG+WALL+EXEC"]
          ["LOWBATT" "SYSLOG+WALL+EXEC"]
          ["FSD" "SYSLOG+WALL+EXEC"]
          ["COMMOK" "SYSLOG+WALL"]
          ["COMMBAD" "SYSLOG+WALL+EXEC"]
          ["SHUTDOWN" "SYSLOG+WALL+EXEC"]
          ["REPLBATT" "SYSLOG+WALL+EXEC"]
          ["NOCOMM" "SYSLOG+WALL+EXEC"]
          ["NOPARENT" "SYSLOG+WALL+EXEC"]
          ["CAL" "SYSLOG+WALL+EXEC"]
          ["NOTCAL" "SYSLOG+WALL+EXEC"]
          ["OFF" "SYSLOG+WALL+EXEC"]
          ["NOTOFF" "SYSLOG+WALL+EXEC"]
          ["BYPASS" "SYSLOG+WALL+EXEC"]
          ["NOTBYPASS" "SYSLOG+WALL+EXEC"]
        ];
      };
      monitor.mawz-nas = {
        # these can be found at `/usr/syno/etc/ups/upsd.users`
        system = "ups@192.168.0.43";
        user = "monuser";
        passwordFile = config.sops.secrets."mawz-nas/upsd".path;
        type = "slave";
      };
    };
  };
  # notifications
  systemd.user.services.ups-journal-notify = let
    journalNotify = pkgs.writeShellScript "journal-notify" ''
      journalctl -f -u upsmon.service -t notify-cmd | while read -r line; do
        ${pkgs.libnotify}/bin/notify-send -t 60000  UPS "$line"
      done
    '';
  in {
    enable = true;
    after = ["network.target"];
    wantedBy = ["default.target"];
    description = "UPS Journal Entry Notification Service";
    serviceConfig = {
      Type = "simple";
      ExecStart = "${journalNotify}";
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "23.11"; # Did you read the comment?
}
