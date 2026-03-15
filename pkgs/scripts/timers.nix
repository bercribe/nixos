{pkgs, ...}:
pkgs.writeShellScriptBin "timers" ''
  systemctl --user list-timers | grep user-timer
''
