{
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../../modules/clients/mullvad.nix
  ];

  specialisation.china = {
    configuration = {
      time.timeZone = lib.mkForce "Asia/Shanghai";

      users.users.mawz.packages = [
        (pkgs.writeShellScriptBin "cvpn" ''
          nmcli connection up home-lan
          mullvad connect
        '')
      ];

      local.clients.mullvad.enable = true;
    };
  };
}
