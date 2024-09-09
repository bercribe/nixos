{cfg, ...}: {
  imports = [../sops.nix];

  sops.secrets."healthchecks/local/ping-key" = {};
}
