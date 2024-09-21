{
  self,
  config,
  ...
}: {
  # Secrets management
  sops = {
    # update this with `sops secrets.yaml`
    defaultSopsFile = self + /secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/mawz/.config/sops/age/keys.txt";
  };
}
