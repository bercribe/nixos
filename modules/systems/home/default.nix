# `man home-configuration.nix` to view configurable options
{
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [./minimal.nix];

  nixpkgs.config.allowUnfree = true;

  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "mawz";
  home.homeDirectory = "/home/mawz";

  home.shellAliases = {
    cat = "bat";
    csc = "python ${pkgs.scripts}/check_sync_conflicts.py";
    diff = "difft";
    ls = "eza";
    nhs = "nh home switch ~/nixos";
    nrs = "~/nixos/rebuild-switch.sh";
  };

  xdg.configFile."nixpkgs/config.nix".source = ./nixpkgs-config.nix;

  programs.bash = {
    enable = true;
    initExtra = ''
      # Aliases with bash completion
      . ${lib.getExe pkgs.complete-alias}
      alias sctl='systemctl'
      complete -F _complete_alias sctl
      alias jctl='journalctl'
      complete -F _complete_alias jctl
      alias jfu='journalctl -f -u'
      complete -F _complete_alias jfu
    '';
  };

  # ssh config
  # use `ssh-copy-id` to add key to remote
  # `ssh-add` to forward credentials
  programs.ssh = let
    user = "mawz";
    forwardAgent = true;
  in {
    enable = true;
    addKeysToAgent = "yes";
    matchBlocks = {
      judgement = {
        inherit user forwardAgent;
        hostname = "judgement.mawz.dev";
      };
      lovers = {
        inherit forwardAgent;
        user = "root";
        hostname = "lovers.mawz.dev";
      };
      mr-president = {
        inherit user forwardAgent;
        hostname = "mr-president.mawz.dev";
        setEnv = {
          # check /usr/share/terminfo
          TERM = "xterm-color";
        };
      };
      moody-blues = {
        inherit user forwardAgent;
        hostname = "moody-blues.mawz.dev";
      };
      super-fly = {
        inherit user forwardAgent;
        hostname = "super-fly.mawz.dev";
      };
      super-fly-decrypt = {
        hostname = "super-fly.mawz.dev";
        port = 2222;
        user = "root";
      };
    };
  };

  programs.git = {
    enable = true;
    userName = "mawz";
    userEmail = "mawz@hey.com";
    difftastic.enable = true;
  };

  programs.jujutsu = {
    enable = true;
    settings = {
      user = {
        name = "mawz";
        email = "mawz@hey.com";
      };
    };
  };

  # Theme settings
  stylix = {
    enable = true;
    image = ./wallpaper.jpg;
    polarity = "dark";
    base16Scheme = "${pkgs.base16-schemes}/share/themes/everforest-dark-hard.yaml";
    cursor = {
      package = pkgs.rose-pine-cursor;
      name = "BreezeX-RosePineDawn-Linux";
      size = 32;
    };
  };
  # needed for stylix theming
  programs.btop.enable = true;
  programs.foot.enable = true;
  programs.ghostty.enable = true;
  programs.zellij.enable = true;
}
