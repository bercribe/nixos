{
  self,
  config,
  lib,
  ...
}: let
  cfg = config.network.sshServer;

  highwayStarKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJ9n+c6dnlsSg6BQqUuljx5UaUFRO0tz9MbdweCY1m4c";
  mawzHueKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIK++5T0hkrduDlpMfdtDh874EqXc4BTPvTzym3chIgHr";
  judgementKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIF9Wk9adw93SEYRYhiYbP6gonU3TCFtHWDpRYtkipkLc";
  superFlyKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKXbugt7AceFpzb4ftHnCRHW7TpTbp7S2cqzHcXJlvH1";
in {
  options.network.sshServer = {
    enableOpenssh = lib.mkEnableOption "openssh";

    createHostUsers = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether to create authorized users for hosts";
    };
  };

  config = {
    users.users.mawz.openssh.authorizedKeys.keys = [highwayStarKey mawzHueKey judgementKey superFlyKey];

    services.openssh.enable = lib.mkIf cfg.enableOpenssh true;

    users.groups.hosts = lib.mkIf cfg.createHostUsers {};
    users.users.highway-star = lib.mkIf cfg.createHostUsers {
      isNormalUser = true;
      group = "hosts";
      openssh.authorizedKeys.keys = [highwayStarKey];
    };
    users.users.mawz-hue = lib.mkIf cfg.createHostUsers {
      isNormalUser = true;
      group = "hosts";
      openssh.authorizedKeys.keys = [mawzHueKey];
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
