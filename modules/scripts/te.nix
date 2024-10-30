{pkgs, ...}:
pkgs.writeShellScriptBin "te" ''
  # te.sh - typst edit
  # Usage: `te <file>`

  touch $1

  ${pkgs.typst}/bin/typst watch $1 &> /dev/null &
  ${pkgs.zathura}/bin/zathura "''${1%.*}.pdf" &

  # autosave file on write
  $EDITOR -c "autocmd TextChanged,TextChangedI * silent write" $1

  trap "exit" INT TERM
  trap "kill 0" EXIT
''
