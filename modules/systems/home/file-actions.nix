{
  programs.file-actions = {
    enable = true;
    # The idea here is to allow for easy context transfer between core apps.
    # As of writing, core apps are: system, tmux, zsh, nvim, yazi, and obsidian.
    # Each core app should fulfill 3 capabilities: copy path, invoke actions, and
    # appear in action list.
    # Additional oneshot commands are also nice to include here.
    actions = [
      # core
      "nvim"
      "oo"
      "opn"
      ''bb foot -D "$d"''
      ''cd "$d" && zsh''
      ''st "$d"''
      ''tmux new-window -c "$d"''
      ''tmux split-window -c "$d"''
      ''yazi "$d"''
      # oneshot
      "cpath"
      "encrypt-pdf"
      "epub-clean"
      "gtgh --path"
      "inkscape"
      "printdoc"
      "removeexif"
      "shrinkvid"
      "zvb"
      ''csc "$d"''
      ''rsc "$d"''
    ];
  };
}
