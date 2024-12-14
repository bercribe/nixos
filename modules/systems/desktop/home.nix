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

  # to apply these, visit about:support and click "Refresh Firefox..."
  programs.firefox = {
    enable = true;
    profiles.mawz = {
      isDefault = true;
      search = {
        default = "Kagi";
        force = true;
        engines = {
          "Kagi" = {
            urls = [
              {template = "https://kagi.com/search?q={searchTerms}";}
              {
                template = "https://kagi.com/api/autosuggest?q={searchTerms}";
                type = "application/x-suggestions+json";
              }
            ];
            iconUpdateUrl = "https://assets.kagi.com/v2/favicon-32x32.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = ["@kagi"];
          };
          "Nix Packages" = {
            urls = [{template = "https://search.nixos.org/packages?query={searchTerms}";}];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@np"];
          };
          "Nix Options" = {
            urls = [{template = "https://search.nixos.org/options?query={searchTerms}";}];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@no"];
          };
          "Home Manager" = {
            urls = [{template = "https://home-manager-options.extranix.com/?query={searchTerms}";}];
            icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
            definedAliases = ["@hm"];
          };
          "Github" = {
            urls = [{template = "https://github.com/search?type=code&q={searchTerms}";}];
            iconUpdateUrl = "https://github.githubassets.com/favicons/favicon-dark.png";
            updateInterval = 24 * 60 * 60 * 1000; # every day
            definedAliases = ["@gh"];
          };
        };
      };
    };
  };

  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-vscode-remote.remote-ssh
    ];
  };

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.everforest-gtk-theme;
      name = "Everforest-Dark";
    };
  };

  # default apps
  xdg.mimeApps = {
    enable = true;
    defaultApplications = osConfig.xdg.mime.defaultApplications;
  };
  # home manager keeps reordering these entries, backing up the old version,
  # then refusing to delete the backup automatically.
  # just force overwrite
  xdg.configFile."mimeapps.list".force = true;

  # needed for stylix theming
  programs.alacritty.enable = true;
  programs.btop.enable = true;
  programs.fzf.enable = true;
  programs.tmux.enable = true;
  stylix.targets.firefox.profileNames = ["mawz"];
}
