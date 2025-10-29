{...}: {
  imports = let
    rootDir = ../..;
  in [
    (rootDir + /modules/systems/home)
  ];

  local.yazi.keybinds = {
    goto-zvault = {
      bind = ["g" "z"];
      command = "cd /zvault";
    };
  };
  local.programs.sf.directories = ["/zvault/shared"];

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "23.11";
}
