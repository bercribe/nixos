{
  pkgs,
  config,
  ...
}: let
  healthchecksBase = {
    endpoint,
    remote ? false,
    extra ? "",
  }: ''
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
    }/$pingKey/${endpoint}?create=1" ${extra}
  '';
in {
  writeHealthchecksPingScript = slug:
    pkgs.writeShellScript "hc-ping-${slug}"
    (healthchecksBase {endpoint = slug;});
  writeHealthchecksLogScript = slug:
    pkgs.writeShellScript "hc-log-${slug}"
    (healthchecksBase {
      endpoint = "${slug}/log";
      extra = ''--data-raw "$1"'';
    });
  writeRemoteHealthchecksPingScript = slug:
    pkgs.writeShellScript "remote-hc-ping-${slug}"
    (healthchecksBase {
      endpoint = slug;
      remote = true;
    });
}
