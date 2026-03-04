{pkgs, ...}:
pkgs.writeShellScriptBin "copy" ''
  # copy.sh - https://jvns.ca/til/vim-osc52/
  printf "\033]52;c;%s\007" "$(base64 | tr -d '\n')"
''
