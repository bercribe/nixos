{
  self,
  config,
  pkgs,
  lib,
  ...
}: {
  imports = [
    ../common.nix
    (self + /modules/systems/network/ssh-server.nix)
  ];

  # Secrets
  sops.secrets = {
    ssh-host = {
      path = "/etc/ssh/ssh_host_ed25519_key";
      key = "${config.networking.hostName}/ssh-host";
    };
  };

  # Certs
  sops.secrets."cloudflare/lego" = {
    sopsFile = self + /secrets/common.yaml;
  };
  security.acme = let
    hostNameMapping = {
      "judgement" = "judgement";
      "mawz-vault" = "super-fly";
    };
    hostName = hostNameMapping."${config.networking.hostName}";
    url = "${hostName}.mawz.dev";
  in {
    acceptTerms = true;

    defaults = {
      email = "mawz@hey.com";
      group = config.services.caddy.group;

      dnsProvider = "cloudflare";
      credentialsFile = config.sops.secrets."cloudflare/lego".path;
    };

    certs = {
      "${url}" = {
        extraDomainNames = ["*.${url}"];
      };
    };
  };

  # User env

  environment.systemPackages = with pkgs; [
    lzop # compression with syncoid
    mbuffer # buffering with syncoid
  ];

  # Programs

  # necessary for vscode remote ssh
  programs.nix-ld.enable = true;

  # Enable mosh, the ssh alternative when client has bad connection
  # Opens UDP ports 60000 ... 61000
  programs.mosh.enable = true;

  # Services
  network.sshServer = {
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
      "zpool/services" = {
        useTemplate = ["default"];
        recursive = true;
      };
    };
  };
}
