{
  config,
  lib,
  ...
}: let
  cfg = config.local.programs.nono;
in {
  options.local.programs.nono = with lib;
  with types; {
    enable = mkEnableOption "nono";
    pi.allowedDirs = mkOption {
      type = listOf str;
      description = "Allowed directories for pi profile";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."nono/profiles/pi.json" = {
      force = true;
      text = ''
        {
          "extends": "always-further/pi",
          "meta": {
            "name": "pi"
          },
          "groups": {
            "include": [],
            "exclude": []
          },
          "commands": {
            "allow": [],
            "deny": []
          },
          "workdir": {
            "access": "readwrite"
          },
          "filesystem": {
            "allow": ${builtins.toJSON cfg.pi.allowedDirs},
            "read": [],
            "write": [],
            "allow_file": [],
            "read_file": [],
            "write_file": [],
            "deny": [],
            "bypass_protection": [],
            "suppress_save_prompt": []
          },
          "network": {
            "block": false,
            "allow_domain": [],
            "credentials": [],
            "open_port": [],
            "listen_port": [],
            "custom_credentials": {}
          },
          "env_credentials": {},
          "hooks": {},
          "rollback": {
            "exclude_patterns": [],
            "exclude_globs": []
          }
        }
      '';
    };
  };
}
