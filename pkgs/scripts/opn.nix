{pkgs, ...}:
pkgs.writeShellScriptBin "opn" ''
  xdg-open "$1" 2>/dev/null || open "$1" 2>/dev/null || echo "$1"
''
