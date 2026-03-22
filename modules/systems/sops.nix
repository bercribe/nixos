{
  lib,
  local,
  ...
}: {
  # Secrets management
  sops = {
    # update this with `sops secrets.yaml`
    defaultSopsFile = lib.mkDefault (local.secrets + /sops/secrets.yaml);
    defaultSopsFormat = "yaml";
    age.keyFile = "/secrets/sops/keys.txt";
  };
}
