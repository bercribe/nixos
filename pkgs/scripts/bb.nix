{pkgs, ...}:
pkgs.writeShellScriptBin "bb" ''
  # https://evanhahn.com/scripts-i-wrote-that-i-use-all-the-time/
  exec setsid nohup "$@" &>/dev/null
''
