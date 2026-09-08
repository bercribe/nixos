{
  pkgs,
  lib,
  local,
  ...
}: {
  programs.glide-browser = import ./firefox-base.nix {inherit pkgs lib local;};
}
