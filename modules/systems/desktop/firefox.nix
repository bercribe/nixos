{
  pkgs,
  lib,
  local,
  ...
}: {
  programs.firefox = import ./firefox-base.nix {inherit pkgs lib local;};

  stylix.targets.firefox.profileNames = ["mawz"];
}
