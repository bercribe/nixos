{
  pkgs,
  lib,
  ...
}: let
  tmux = lib.getExe pkgs.tmux;
in
  pkgs.writeShellScriptBin "tsl" ''
    # tsl.sh - tmux switch layout
    ${tmux} select-layout $(cat "$HOME/.config/tmux/$1.layout")
  ''
