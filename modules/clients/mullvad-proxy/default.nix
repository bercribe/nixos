{
  pkgs,
  config,
  lib,
  ...
}: let
  cfg = config.local.clients.mullvad-proxy;

  ns = "mullvad";
  vethHost = "veth-mv-host";
  vethNs = "veth-mv-ns";
  hostIp = "10.200.0.1";
  nsIp = "10.200.0.2";

  # Mullvad WireGuard config values
  address = "10.69.117.208/32";
  dns = "10.64.0.1";
  peer = builtins.elemAt (import ./endpoints.nix).stockholm 15;
  peerPublicKey = peer.public-key;
  peerEndpoint = peer.endpoint;
in {
  options.local.clients.mullvad-proxy = with lib;
  with types; {
    enable = mkEnableOption "persistent SOCKS5 proxy through Mullvad WireGuard";
    port = mkOption {
      type = port;
      default = 1080;
    };
    url = mkOption {
      type = str;
      readOnly = true;
      default = "socks5://${nsIp}:${toString cfg.port}";
      description = "SOCKS5 proxy URL";
    };
  };

  # reference: https://vtimofeenko.com/posts/wireguard-namespace-flake/
  config = lib.mkIf cfg.enable {
    sops.secrets.mullvad-wg-cute-pug = {};

    environment.etc = {
      "netns/${ns}/resolv.conf".text = "nameserver ${dns}";
      # This setting forces the use of resolv.conf instead of dbus interface provided by systemd-resolved
      "netns/${ns}/nsswitch.conf".text = "hosts: dns";
    };

    networking.wireguard.interfaces.wg-mullvad = let
      ip = "${pkgs.iproute2}/bin/ip";
    in {
      ips = [address];
      privateKeyFile = config.sops.secrets.mullvad-wg-cute-pug.path;
      interfaceNamespace = ns;

      preSetup = ''
        # create isolated network namespace
        ${ip} netns add ${ns}
        # create virtual ethernet pair (host <-> namespace bridge)
        ${ip} link add ${vethHost} type veth peer name ${vethNs}
        # move one end into the namespace
        ${ip} link set ${vethNs} netns ${ns}
        # configure host end
        ${ip} addr replace ${hostIp}/24 dev ${vethHost}
        ${ip} link set ${vethHost} up
        # configure namespace end
        ${ip} netns exec ${ns} ip addr replace ${nsIp}/24 dev ${vethNs}
        ${ip} netns exec ${ns} ip link set ${vethNs} up
      '';

      postSetup = ''
        # route all traffic through wireguard
        ${ip} netns exec ${ns} ip route replace default dev wg-mullvad
      '';

      postShutdown = ''
        ${ip} netns del ${ns} 2>/dev/null || true
        ${ip} link del ${vethHost} 2>/dev/null || true
      '';

      peers = [
        {
          publicKey = peerPublicKey;
          endpoint = peerEndpoint;
          allowedIPs = ["0.0.0.0/0" "::/0"];
        }
      ];
    };

    services.microsocks = {
      enable = true;
      ip = nsIp;
      port = cfg.port;
    };

    systemd.services.microsocks = {
      after = ["wireguard-wg-mullvad.service"];
      requires = ["wireguard-wg-mullvad.service"];
      serviceConfig.NetworkNamespacePath = "/var/run/netns/${ns}";
    };
  };
}
