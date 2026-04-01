{
  config,
  lib,
  inputs,
  ...
}: let
  cfg = config.local.healthchecks-secret;
in {
  options.local.healthchecks-secret.enable = lib.mkEnableOption "local healthchecks ping key";

  config = lib.mkIf cfg.enable {
    sops.secrets."healthchecks/local/ping-key" = {
      sopsFile = inputs.secrets + /sops/local.yaml;
    };
  };
}
