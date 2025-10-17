{
  self,
  config,
  ...
}: {
  imports = [
    ../common.nix
    (self + /modules/systems/network/ssh-server.nix)
  ];

  # Config
  local.services.postgresql-tweaks.enable = true;

  # Secrets
  # generate with `ssh-keygen -t ed25519 -N "" -f ./ssh_host_ed25519_key -C "root@<host>"`
  sops.secrets = {
    ssh-host = {
      path = "/etc/ssh/ssh_host_ed25519_key";
      key = "${config.networking.hostName}/ssh-host";
    };
  };

  # Programs

  # necessary for vscode remote ssh
  programs.nix-ld.enable = true;

  # Enable mosh, the ssh alternative when client has bad connection
  # Opens UDP ports 60000 ... 61000
  programs.mosh.enable = true;

  # Services
  local.disk-monitor.headless = true;

  local.sshServer = {
    enableOpenssh = true;
    createHostUsers = true;
  };

  # ZFS snapshots
  services.sanoid = {
    enable = true;
    templates.default = {
      autosnap = true;
      autoprune = true;
      hourly = 36;
      daily = 30;
      monthly = 3;
    };
    datasets = {
      "${
        if config.local ? disko.zpoolName
        then config.local.disko.zpoolName
        else "zpool"
      }/services" = {
        useTemplate = ["default"];
        recursive = true;
      };
    };
  };
}
