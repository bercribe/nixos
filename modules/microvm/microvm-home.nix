{...}: {
  imports = [./pi.nix ../systems/home/minimal.nix];

  home.username = "mawz";
  home.homeDirectory = "/home/mawz";

  local.programs.pi-coding-agent.enable = true;
  local.packages.includeScripts = true;
  local.yazi.useMux = true;

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
