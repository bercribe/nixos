{
  modulesPath,
  config,
  pkgs,
  lib,
  secrets,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko-config.nix

    ../../modules/systems/headless
  ];

  # Secrets
  sops.defaultSopsFile = builtins.toPath "${secrets}/sops/${config.networking.hostName}.yaml";

  boot.loader.grub = {
    # no need to set devices, disko will add all devices that have a EF02 partition to the list already
    # devices = [ ];
    efiSupport = true;
    efiInstallAsRemovable = true;
  };

  networking.hostName = "echoes"; # Define your hostname.

  # User env
  home-manager.users.mawz = import ./home.nix;

  # TODO: fix disk monitor
  local.disk-monitor.enable = lib.mkForce false;

  # SSH security
  services.fail2ban.enable = true;

  security.pam.services.sshd.text = let
    notifyLogin = pkgs.writeShellScript "notify-login.sh" ''
      mkdir -p "$HOME/.ssh"
      ip_file="$HOME/.ssh/last_ip"
      ip=$(echo $SSH_CONNECTION | awk '{print $1}')
      last_ip=$(cat $ip_file 2>/dev/null)
      echo "$ip" > $ip_file

      if [ "$ip" != "$last_ip" ]; then
        message="SSH login detected on $(hostname) at $(date) by user $PAM_USER from $ip"
        echo "$message" | ${pkgs.postfix}/bin/sendmail root
      fi
    '';
  in
    lib.mkDefault (lib.mkAfter ''
      session optional ${pkgs.pam}/lib/security/pam_exec.so ${notifyLogin}
    '');

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system - see https://nixos.org/manual/nixos/stable/#sec-upgrading for how
  # to actually do that.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "25.05"; # Did you read the comment?
}
