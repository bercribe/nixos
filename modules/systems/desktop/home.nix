# `man home-configuration.nix` to view configurable options
{
  self,
  config,
  osConfig,
  pkgs,
  lib,
  stylix,
  ...
}: {
  imports = [
    ./firefox.nix
  ];

  # model for mutable config files:
  # systemd.user.tmpfiles.rules = let
  #   conf = lib.generators.toINI {} {
  #     example.conf = true;
  #   };
  #   escapedConf = with lib; concatStringsSep "\\n" (splitString "\n" conf);
  # in [
  #   "f+ ${config.home.homeDirectory}/.config/dir/file.ini 644 mawz users - ${escapedConf}"
  # ];

  programs.bash = {
    enable = true;
    # fixes tab completion to use dircolors
    # dircolors must be evaluated before colored-stats is enabled
    bashrcExtra = ''
      eval $(${pkgs.coreutils}/bin/dircolors -b ~/.dir_colors)
      bind 'set colored-stats on'
    '';
  };
  programs.dircolors = {
    enable = true;
    settings = {
      OTHER_WRITABLE = "30;46";
    };
  };

  programs.keepassxc = {
    enable = true;
    settings = {
      Browser.Enabled = true;
      FdoSecrets.Enabled = true;
      GUI.ApplicationTheme = "dark";
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-vscode-remote.remote-ssh
    ];
  };

  programs.imv = {
    enable = true;
    settings = {
      options.background = "checks";
      binds = {
        bb = "background 000000";
        bw = "background ffffff";
        bc = "background checks";
      };
    };
  };

  programs.spotify-player = {
    enable = true;
    settings = {
      notify_timeout_in_secs = 10;
    };
  };

  programs.zellij = {
    enable = true;
    enableBashIntegration = true;
  };

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.everforest-gtk-theme;
      name = "Everforest-Dark";
    };
  };

  # default apps
  xdg = {
    mimeApps = {
      enable = true;
      defaultApplications = osConfig.xdg.mime.defaultApplications;
      associations.added = osConfig.xdg.mime.addedAssociations;
    };
    desktopEntries = {
      spotify_player = {
        name = "Spotify Player";
        exec = "spotify_player";
        terminal = true;
      };
    };
  };
  # home manager keeps reordering these entries, backing up the old version,
  # then refusing to delete the backup automatically.
  # just force overwrite
  xdg.configFile."mimeapps.list".force = true;

  stylix.targets.firefox.profileNames = ["mawz"];
}
