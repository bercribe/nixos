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

  healthchecksPing = slug:
    pkgs.writeShellScript "hc-ping-${slug}"
    (healthchecksBase {endpoint = slug;});
  healthchecksLog = slug:
    pkgs.writeShellScript "hc-log-${slug}"
    (healthchecksBase {
      endpoint = "${slug}/log";
      extra = ''--data-raw "$1"'';
    });
in {
  writeHealthchecksPingScript = healthchecksPing;
  writeHealthchecksLogScript = healthchecksLog;
  writeHealthchecksCombinedScript = slug: command:
    pkgs.writeShellScript "hc-combined-${slug}" ''
      set +e
      logs=$(${command})
      code=$?
      set -e

      ${healthchecksLog slug} "$logs"

      if [ "$code" -eq "0" ]; then
        ${healthchecksPing slug}
      fi
    '';
  writeRemoteHealthchecksPingScript = slug:
    pkgs.writeShellScript "remote-hc-ping-${slug}"
    (healthchecksBase {
      endpoint = slug;
      remote = true;
    });
}
