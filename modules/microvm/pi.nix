{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.local.programs.pi-coding-agent;
in {
  options.local.programs.pi-coding-agent = with lib;
  with types; {
    enable = mkEnableOption "pi-coding-agent";

    instructions = mkOption {
      type = lines;
      default = "";
      description = ''
        Define custum guidance for the agent; this value is written to
        {file}`~/.pi/agent/AGENTS.md`.
      '';
      example = ''
        - Always respond with emojis
        - Only use git commands when explicitly requested
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.file.".pi/agent/AGENTS.md" = lib.mkIf (cfg.instructions != "") {
      text = cfg.instructions;
    };

    programs.tmux.extraConfig = lib.mkIf config.programs.tmux.enable ''
      # https://github.com/badlogic/pi-mono/blob/main/packages/coding-agent/docs/tmux.md
      set -g extended-keys on
      set -g extended-keys-format csi-u
    '';
  };
}
