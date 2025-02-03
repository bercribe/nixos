{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.local.sshServer;

  # get public key: `sudo ssh-keygen -f ~/.ssh/id_ed25519 -y`
  heavensDoorKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK++5T0hkrduDlpMfdtDh874EqXc4BTPvTzym3chIgHr";
  highwayStarKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9n+c6dnlsSg6BQqUuljx5UaUFRO0tz9MbdweCY1m4c";
  judgementKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF9Wk9adw93SEYRYhiYbP6gonU3TCFtHWDpRYtkipkLc";
  moodyBluesKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJuSl7sYo+gy/CYBw800CsMdcFLEG03Gn/BjMqtTCuAi";
  superFlyKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXbugt7AceFpzb4ftHnCRHW7TpTbp7S2cqzHcXJlvH1";
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

    services.openssh.enable = lib.mkIf cfg.enableOpenssh true;

    users.groups.hosts = lib.mkIf cfg.createHostUsers {};
    users.users.highway-star = lib.mkIf cfg.createHostUsers {
      isNormalUser = true;
      group = "hosts";
      openssh.authorizedKeys.keys = [highwayStarKey];
    };
    users.users.heavens-door = lib.mkIf cfg.createHostUsers {
      isNormalUser = true;
      group = "hosts";
      openssh.authorizedKeys.keys = [heavensDoorKey];
    };
    users.users.judgement = lib.mkIf cfg.createHostUsers {
      isNormalUser = true;
      group = "hosts";
      openssh.authorizedKeys.keys = [judgementKey];
    };
    users.users.super-fly = lib.mkIf cfg.createHostUsers {
      isNormalUser = true;
      group = "hosts";
      openssh.authorizedKeys.keys = [superFlyKey];
    };
  };
}
