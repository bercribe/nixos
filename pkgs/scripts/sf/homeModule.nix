{
  config,
  lib,
  ...
}: let
  cfg = config.local.programs.sf;
in {
  options.local = with lib;
  with types; {
    programs.sf.directories = mkOption {
      type = listOf str;
      default = ["$HOME"];
      description = "List of directories to select from when creating a session";
    };
  };

  config = {
    home.sessionVariables.SF_DIRS = lib.concatStringsSep ":" cfg.directories;
  };
}
