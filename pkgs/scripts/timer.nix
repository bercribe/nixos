{
  pkgs,
  lib,
  ...
}: let
  notify-send = "${pkgs.libnotify}/bin/notify-send";
in
  pkgs.writeShellScriptBin "timer" ''
    sleep "$1"
    ${notify-send} 'timer complete' "$1"
  ''
