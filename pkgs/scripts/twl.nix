{
  pkgs,
  lib,
  ...
}: let
  tmux = lib.getExe pkgs.tmux;
in
  pkgs.writeShellScriptBin "twl" ''
    # twl.sh - tmux write layout
    ${tmux} display-message -p '#{window_layout}' > "$HOME/.config/tmux/$1.layout"
  ''
