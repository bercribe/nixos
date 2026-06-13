{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.local;
in {
  imports = [
    ./nono.nix
    ./tmux.nix
    ./vim.nix
    ./yazi.nix
    ./zsh.nix
    ../../../constants
  ];

  options.local = with lib;
  with types; {
    packages.includeScripts = mkEnableOption "scripts";
  };

  config = {
    home.packages = let
      packages = config.local.constants.packages;
    in
      packages.core ++ (lib.optionals cfg.packages.includeScripts packages.scripts);

    home.sessionVariables = {
      # colored man pages
      MANROFFOPT = "-P -c";
      MANPAGER = "less --use-color -Dd+r -Du+b";
    };

    home.shellAliases = {
      cat = "bat";
      cd = "z";
      diff = "delta";
    };

    # shell integrations
    programs.fzf.enable = true;
    programs.zoxide.enable = true;
    programs.atuin = {
      enable = true;
      flags = [
        "--disable-up-arrow"
      ];
      settings = {
        inline_height = 16;
      };
      # improves performance on zfs systems
      daemon.enable = true;
    };
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    programs.delta = {
      enable = true;
      package = pkgs.delta;
      enableGitIntegration = true;
      options = {
        features = "decorations";
        decorations = {
          file-decoration-style = "none";
          file-style = "bold yellow ul";
          hunk-header-decoration-style = "none";
        };
      };
    };

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
        "printdoc"
        "removeexif"
        "shrinkvid"
        "zvb"
        ''csc "$d"''
        ''rsc "$d"''
      ];
    };

    local.programs.nono = {
      enable = true;
      pi.allowedDirs = ["~/sources"];
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;
  };
}
