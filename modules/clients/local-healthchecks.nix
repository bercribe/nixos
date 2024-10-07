{
  self,
  cfg,
  ...
}: {
  imports = [(self + /modules/sops.nix)];

  sops.secrets."healthchecks/local/ping-key" = {
    sopsFile = self + /secrets/common.yaml;
  };
}
