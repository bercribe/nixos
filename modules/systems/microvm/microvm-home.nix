{workspace, ...}: {
  imports = [./pi.nix ../home/minimal.nix];

  home.username = "mawz";
  home.homeDirectory = "/home/mawz";

  local.programs.pi-coding-agent.enable = true;
  local.packages.includeScripts = true;
  local.yazi.useMux = true;
  programs.session-tool.directories = [workspace];

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
