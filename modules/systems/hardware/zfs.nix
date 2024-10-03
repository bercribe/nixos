{
  self,
  config,
  pkgs,
  ...
}: {
  imports = [
    (self + /modules/sops.nix)
    (self + /modules/systems/network/ssh.nix)
    (self + /modules/services/postfix.nix)
  ];

  sops.secrets = {
    zfs-drive = {};
  };

  # hosts ssh server on boot for decrypting drives
  boot.initrd = {
    availableKernelModules = ["r8169"];
    network = {
      # This will use udhcp to get an ip address.
      # Make sure you have added the kernel module for your network driver to `boot.initrd.availableKernelModules`,
      # so your initrd can load it!
      # Static ip addresses might be configured using the ip argument in kernel command line:
      # https://www.kernel.org/doc/Documentation/filesystems/nfs/nfsroot.txt
      enable = true;
      udhcpc.enable = true;
      ssh = {
        enable = true;
        # To prevent ssh clients from freaking out because a different host key is used,
        # a different port for ssh is useful (assuming the same host has also a regular sshd running)
        port = 2222;
        # hostKeys paths must be unquoted strings, otherwise you'll run into issues with boot.initrd.secrets
        # the keys are copied to initrd from the path specified; multiple keys can be set
        # you can generate any number of host keys using
        # `ssh-keygen -t ed25519 -N "" -f /secrets/initrd/ssh_host_ed25519_key`
        hostKeys = [/secrets/initrd/ssh_host_ed25519_key];
        # public ssh key used for login
        authorizedKeys = config.users.users.mawz.openssh.authorizedKeys.keys;
      };
      postCommands = ''
        # Import boot pool
        zpool import zpool
        # Add the load-key command to the .profile
        echo "zfs load-key -a; killall zfs" >> /root/.profile
      '';
    };
  };

  services.zfs.autoScrub.enable = true;

  services.zfs.zed = {
    # this option does not work; will return error
    enableMail = false;
    settings = {
      ZED_DEBUG_LOG = "/tmp/zed.debug.log";
      ZED_EMAIL_ADDR = ["root"];
      ZED_EMAIL_PROG = "${pkgs.mailutils}/bin/mail";
      ZED_EMAIL_OPTS = "@ADDRESS@";

      ZED_NOTIFY_INTERVAL_SECS = 3600;
      ZED_NOTIFY_VERBOSE = true;

      ZED_USE_ENCLOSURE_LEDS = true;
      ZED_SCRUB_AFTER_RESILVER = true;
    };
  };
}
