{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.local.sshServer;

  # get public key: `sudo ssh-keygen -f ~/.ssh/id_ed25519 -y`
  heavensDoorKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILhVLYr/28cVdPf+i4jCFCJ8jt+kNJumN73WL77ww8f2";
  highwayStarKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM9y6wTI2WarxWkohtI5enYZe6XcBzSlc1YD/9pvuehY";
  judgementKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIER64QQIhquhTeMpVMzMI8kjNV6ch80b48l/TLOtDiiO";
  moodyBluesKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDf6DMdjF6Fsp8GmVNg7soTxqi0iqR0berZ3tbFJarhp";
  superFlyKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPjusmTfA4UTuMdrnBl3n66inecJF34mqtNp1avGp/nd";
in {
  options.local.sshServer = {
    enableOpenssh = lib.mkEnableOption "openssh";

    createHostUsers = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether to create authorized users for hosts";
    };
  };

  config = {
    users.users.mawz.openssh.authorizedKeys.keys = [heavensDoorKey highwayStarKey judgementKey moodyBluesKey superFlyKey];

    services.openssh = {
      enable = cfg.enableOpenssh;
      settings.PasswordAuthentication = false;
    };

    users.groups.hosts = lib.mkIf cfg.createHostUsers {};
    users.users.heavens-door = lib.mkIf cfg.createHostUsers {
      isNormalUser = true;
      group = "hosts";
      openssh.authorizedKeys.keys = [heavensDoorKey];
    };
    users.users.highway-star = lib.mkIf cfg.createHostUsers {
      isNormalUser = true;
      group = "hosts";
      openssh.authorizedKeys.keys = [highwayStarKey];
    };
    users.users.judgement = lib.mkIf cfg.createHostUsers {
      isNormalUser = true;
      group = "hosts";
      openssh.authorizedKeys.keys = [judgementKey];
    };
    users.users.moody-blues = lib.mkIf cfg.createHostUsers {
      isNormalUser = true;
      group = "hosts";
      openssh.authorizedKeys.keys = [moodyBluesKey];
    };
    users.users.super-fly = lib.mkIf cfg.createHostUsers {
      isNormalUser = true;
      group = "hosts";
      openssh.authorizedKeys.keys = [superFlyKey];
    };
  };
}
