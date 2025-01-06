{
  self,
  cfg,
  ...
}: {
  sops.secrets."healthchecks/local/ping-key" = {
    sopsFile = self + /secrets/common.yaml;
  };
}
