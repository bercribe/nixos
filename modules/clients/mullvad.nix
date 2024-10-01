{pkgs, ...}: {
  # currently required: https://discourse.nixos.org/t/connected-to-mullvadvpn-but-no-internet-connection/35803/8
  services.resolved.enable = true;
  services.mullvad-vpn.enable = true;
  # for GUI
  services.mullvad-vpn.package = pkgs.mullvad-vpn;
}
