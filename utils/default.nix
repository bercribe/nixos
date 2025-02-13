{
  pkgs,
  config,
  ...
}: let
  healthchecksBase = remote: ''
    pingKey="$(cat ${config
      .sops
      .secrets
      ."healthchecks/${
        if remote
        then "remote"
        else "local"
      }/ping-key"
      .path})"
    ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "${
      if remote
      then "https://hc-ping.com"
      else "http://healthchecks.lan/ping"
    }/$pingKey/'';
in {
  writeHealthchecksPingScript = slug:
    pkgs.writeShellScript "hc-ping-${slug}" ''
      ${healthchecksBase false}${slug}"
    '';
  writeHealthchecksLogScript = slug:
    pkgs.writeShellScript "hc-log-${slug}" ''
      ${healthchecksBase false}${slug}/log" --data-raw "$1"
    '';
  writeRemoteHealthchecksPingScript = slug:
    pkgs.writeShellScript "remote-hc-ping-${slug}" ''
      ${healthchecksBase true}${slug}"
    '';
}
