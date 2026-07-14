{workspace, ...}: {
  imports = [./pi.nix ../home/minimal.nix];

  home.username = "mawz";
  home.homeDirectory = "/home/mawz";

  local.programs.pi-coding-agent = {
    enable = true;
    instructions = ''
      - be consice with code comments - only use them when necessary to explain "why" or to provide a high level summary
      - I will often edit files you have worked on - do not revert my changes. Integrate them into the final result
      - You are running in a VM, building nix packages will not work. Prompt me to build them for you
    '';
  };

  local.packages.includeScripts = true;
  local.yazi.useMux = true;
  programs.session-tool = {
    enable = true;
    directories = [workspace];
  };

  home.stateVersion = "25.11";
  programs.home-manager.enable = true;
}
