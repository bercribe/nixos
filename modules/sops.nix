{config, ...}: {
  # Secrets management
  sops = {
    # update this with `sops secrets.yaml`
    defaultSopsFile = ../secrets/secrets.yaml;
    defaultSopsFormat = "yaml";
    age.keyFile = "/home/mawz/.config/sops/age/keys.txt";
  };
}
