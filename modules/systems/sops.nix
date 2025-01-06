{
  self,
  config,
  lib,
  ...
}: {
  # Secrets management
  sops = {
    # update this with `sops secrets.yaml`
    defaultSopsFile = lib.mkDefault (self + /secrets/secrets.yaml);
    defaultSopsFormat = "yaml";
    age.keyFile = "/secrets/sops/keys.txt";
  };
  environment.variables.SOPS_AGE_KEY_FILE = config.sops.age.keyFile;
}
