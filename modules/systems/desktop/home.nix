# `man home-configuration.nix` to view configurable options
{
  self,
  config,
  pkgs,
  lib,
  stylix,
  ...
}: {
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mawz";
  home.homeDirectory = "/home/mawz";

  # Git config
  programs.git = {
    enable = true;
    userName = "mawz";
    userEmail = "mawz@hey.com";
  };

  # generate key: `ssh-keygen -t ed25519 -C "mawz@hey.com"`
  # ssh config
  # use `ssh-copy-id` to add key to remote
  # `ssh-add` to forward credentials
  programs.ssh = {
    enable = true;
    forwardAgent = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      mawz-nuc = {
        hostname = "192.168.0.54";
        user = "mawz";
      };
      mawz-nas = {
        hostname = "192.168.0.43";
        user = "mawz";
        setEnv = {
          # check /usr/share/terminfo
          TERM = "xterm-color";
        };
      };
      mawz-nvr = {
        hostname = "192.168.0.32";
        user = "mawz";
      };
      mawz-vault = {
        hostname = "192.168.0.51";
        user = "mawz";
      };
      mawz-vault-decrypt = {
        hostname = "192.168.0.51";
        port = 2222;
        user = "root";
      };
    };
  };

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
    extensions = with pkgs.vscode-extensions; [
      bbenoist.nix
      ms-vscode-remote.remote-ssh
    ];
  };

  programs.neovim = {
    enable = true;
    extraConfig = ''
      "Use system clipboard
      set clipboard=unnamedplus
    '';
  };

  # inspiration:
  #   - https://github.com/gokcehan/lf/blob/master/doc.md
  #   - https://github.com/gokcehan/lf/wiki/Tips
  #   - https://github.com/vimjoyer/lf-nix-video
  programs.lf = {
    enable = true;
    commands = let
      copy-cmd = "${pkgs.wl-clipboard}/bin/wl-copy";
    in {
      copy-path = ''
        ''${{
        ${copy-cmd} $f
        }}
      '';
      copy-name = ''
        ''${{
        basename "$f" | ${copy-cmd}
        }}
      '';
      copy-dir = ''
        ''${{
        dirname "$f" | ${copy-cmd}
        }}
      '';
      copy-files = ''
        ''${{
          echo "$fx" | awk '{ print "file://" $0 }' | ${copy-cmd} -t text/uri-list
        }}
      '';
      dragon-out = ''
        ''${{
          readarray -t files <<<"$fx"
          ${pkgs.xdragon}/bin/xdragon -a -x "''${files[@]}"
        }}
      '';
    };
    keybindings = {
      y = null;
      yy = "copy";
      yp = "copy-path";
      yn = "copy-name";
      yd = "copy-dir";
      yf = "copy-files";
      yo = "dragon-out";
      a = "push %mkdir<space>";
      gn = "cd /mnt/mawz-nas";
      gv = "cd /mnt/mawz-vault";
      gd = "cd /mnt/distant-disk";
    };
    previewer.source = pkgs.writeShellScript "pv.sh" ''
      #!/bin/sh

      shopt -s nocasematch
      case "$1" in
          *.avi | *.bmp | *.gif | *.jpg | *.jpeg | *.mov | *.mpg | *.mp4 | *.pcx | *.png | *.psd | *.thm | *.wav)
              ${pkgs.exiftool}/bin/exiftool -S -DateTimeOriginal -MediaCreateDate -FileModifyDate "$1";
              echo "--------------------------------"; ${pkgs.exiftool}/bin/exiftool "$1";;
          *.tar*) tar tf "$1";;
          *.zip) unzip -l "$1";;
          *.rar) unrar l "$1";;
          *.7z) 7z l "$1";;
          *.pdf) pdftotext "$1" -;;
          *) highlight -O ansi "$1" || cat "$1";;
      esac
    '';
  };

  gtk = {
    enable = true;
    iconTheme = {
      package = pkgs.unstable.everforest-gtk-theme;
      name = "Everforest-Dark";
    };
  };

  # needed for stylix theming
  programs.alacritty.enable = true;
  programs.btop.enable = true;
  programs.fzf.enable = true;
  programs.tmux.enable = true;
  stylix.targets.firefox.profileNames = ["mawz"];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
