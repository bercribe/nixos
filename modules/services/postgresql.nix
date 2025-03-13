{config, ...}: {
  services.postgresql.dataDir = "/services/postgres/${config.services.postgresql.package.psqlSchema}";
}
