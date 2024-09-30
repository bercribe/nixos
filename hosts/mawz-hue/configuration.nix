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
    "mawz-nas/upsd" = {};
  };

  # Bootloader
  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "mawz-hue"; # Define your hostname.
  networking.hostId = "0149bc0f"; # Should be unique among ZFS machines

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

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "24.05"; # Did you read the comment?
}
