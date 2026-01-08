{
  config,
  lib,
  ...
}: let
  cfg = config.local.programs.st;
in {
  options.local = with lib;
  with types; {
    programs.st = {
      directories = mkOption {
        type = listOf str;
        default = ["$HOME"];
        description = "List of directories to select from when creating a session";
      };
      extraFdFlags = mkOption {
        type = listOf str;
        default = [];
        description = "Extra flags passed to fd";
      };
    };
  };

  config = {
    home.sessionVariables.SF_DIRS = lib.concatStringsSep ":" cfg.directories;
    home.sessionVariables.SF_FD_FLAGS = lib.concatStringsSep " " cfg.extraFdFlags;
  };
}
