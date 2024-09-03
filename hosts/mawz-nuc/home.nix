# `man home-configuration.nix` to view configurable options
{config, ...}: {
  imports = [
    ../../modules/home
  ];
}
