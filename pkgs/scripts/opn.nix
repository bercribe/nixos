{pkgs, ...}:
pkgs.writeShellScriptBin "opn" ''
  opener=$(command -v xdg-open || command -v open)
  for f in "$@"; do $opener "$f" 2>/dev/null || echo "$f"; done
''
