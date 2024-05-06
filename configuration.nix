{
  config,
  pkgs,
  options,
  ...
}: let
  hostname = "FIXME"; # to alllow per-machine config
in {
  networking.hostName = hostname;

  imports = [
    (/home/mawz/nixos/hosts + "/${hostname}/configuration.nix")
  ];
}
