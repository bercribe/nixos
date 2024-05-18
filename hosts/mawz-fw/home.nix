# `man home-configuration.nix` to view configurable options
{
  config,
  pkgs,
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

  # ssh config
  # use `ssh-copy-id` to add key to remote
  programs.ssh = {
    enable = true;
    matchBlocks = {
      mawz-nuc = {
        port = 22;
        hostname = "192.168.0.54";
        user = "mawz";
      };
    };
  };

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
