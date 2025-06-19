{
  config,
  pkgs,
  lib,
  ...
}: let
  cfg = config.local.services.hledger-web;

  group = "ledger";
  ledgerDir = "/zvault/shared/finances/ledger";
  port = 17071;
in {
  options.local.services.hledger-web.enable = lib.mkEnableOption "hledger-web";

  config = lib.mkIf cfg.enable {
    services.hledger-web = {
      enable = true;
      inherit port;
      stateDir = ledgerDir;
      journalFiles = ["main.ledger"];
      allow = "view"; # TODO: edit
    };
    systemd.services.hledger-web.serviceConfig.Group = lib.mkForce group;

    local.reverseProxy = {
      enable = true;
      services.hledger-web = {
        inherit port;
      };
    };
  };
}
