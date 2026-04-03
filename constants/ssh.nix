{lib, ...}: {
  options.local.constants.ssh = with lib;
  with types; {
    user-keys = mkOption {
      type = attrsOf (submodule {
        options = {
          publicKey = mkOption {
            type = str;
            description = "SSH public key";
          };
          authorizeMawz = mkOption {
            type = bool;
            default = false;
            description = "Whether this key authorizes the mawz user";
          };
          createHostUser = mkOption {
            type = bool;
            default = false;
            description = "Whether to create a dedicated host user for this key";
          };
        };
      });
      description = "SSH public keys for user accounts (for authenticating users to servers)";
    };
    host-keys = mkOption {
      type = attrsOf str;
      description = "SSH public keys for host identification (for known_hosts)";
    };
  };

  config.local.constants.ssh = {
    # get public key: `sudo ssh-keygen -f ~/.ssh/id_ed25519 -y`
    user-keys = {
      heavens-door = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILhVLYr/28cVdPf+i4jCFCJ8jt+kNJumN73WL77ww8f2";
        authorizeMawz = true;
        createHostUser = true;
      };
      highway-star = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM9y6wTI2WarxWkohtI5enYZe6XcBzSlc1YD/9pvuehY";
        authorizeMawz = true;
        createHostUser = true;
      };
      judgement = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIER64QQIhquhTeMpVMzMI8kjNV6ch80b48l/TLOtDiiO";
        createHostUser = true;
      };
      moody-blues = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDf6DMdjF6Fsp8GmVNg7soTxqi0iqR0berZ3tbFJarhp";
        createHostUser = true;
      };
      super-fly = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPjusmTfA4UTuMdrnBl3n66inecJF34mqtNp1avGp/nd";
        createHostUser = true;
      };
      whitesnake = {
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIHZiopOhkZd+CcuGL3d4Kdm+/WxmqtEjZqBEr8iUJNhT";
        authorizeMawz = true;
      };
    };

    # get public key: `sudo ssh-keygen -f /etc/ssh/ssh_host_ed25519_key -y`
    host-keys = {
      mr-president = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPmljHSvr8veywr2SIWLw8oP0jH75y45KTqROo09yzBk";
      judgement = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMNTo4tnqG7zk+yAmA7JUOapVjhSWkhdqSoEor9q+KbL";
      moody-blues = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIBUCKXB7muqmoovAblrX2znV3PUejkIqqZ4OxSMGuXGE";
      super-fly = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICdZUinVNS9d3LOmDKYWq4kEb6iO1uKaJOGhBZ4cQ6/h";
    };
  };
}
