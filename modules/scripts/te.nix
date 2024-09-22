{pkgs, ...}:
pkgs.writeShellScriptBin "te" ''
  # te.sh - typst edit
  # Usage: `te <file>`

  touch $1

  ${pkgs.typst-live}/bin/typst-live $1 &> /dev/null &
  ${pkgs.vim}/bin/vim $1
  # autosave file on write
  # ${pkgs.vim}/bin/vim -c "autocmd TextChanged,TextChangedI * silent write" $1

  trap "exit" INT TERM
  trap "kill 0" EXIT
''
