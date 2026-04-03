{
  config,
  lib,
  ...
}: let
  cfg = config.local.sshServer;
  userKeys = config.local.constants.ssh.user-keys;

  mawzKeys = lib.filterAttrs (_: v: v.authorizeMawz) userKeys;
  hostUserKeys = lib.filterAttrs (_: v: v.createHostUser) userKeys;

  hostUsers = lib.mapAttrs (name: value:
    lib.mkIf cfg.createHostUsers {
      isNormalUser = true;
      group = "hosts";
      openssh.authorizedKeys.keys = [value.publicKey];
    })
  hostUserKeys;
in {
  options.local.sshServer = {
    createHostUsers = lib.mkOption {
      type = lib.types.bool;
      default = false;
      example = true;
      description = "Whether to create authorized users for hosts";
    };
  };

  config = {
    users.users =
      {
        mawz.openssh.authorizedKeys.keys = lib.mapAttrsToList (_: v: v.publicKey) mawzKeys;
      }
      // hostUsers;

    services.openssh = {
      enable = lib.mkDefault true;
      settings = {
        PasswordAuthentication = false;
        KbdInteractiveAuthentication = false;
        PermitRootLogin = "no";
        AllowUsers = ["mawz"] ++ (lib.optionals cfg.createHostUsers (builtins.attrNames hostUserKeys));
      };
    };

    users.groups.hosts = lib.mkIf cfg.createHostUsers {};
  };
}
