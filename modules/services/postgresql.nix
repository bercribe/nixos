{
  config,
  lib,
  ...
}: let
  cfg = config.local.services.postgresql-tweaks;
in {
  options.local.services.postgresql-tweaks.enable = lib.mkEnableOption "postgresql tweaks";

  config = lib.mkIf cfg.enable {
    services.postgresql.dataDir = "/services/postgres/${config.services.postgresql.package.psqlSchema}";
  };
}
