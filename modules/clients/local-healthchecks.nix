{secrets, ...}: {
  sops.secrets."healthchecks/local/ping-key" = {
    sopsFile = secrets + /sops/common.yaml;
  };
}
