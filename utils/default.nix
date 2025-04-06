{
  pkgs,
  config,
  ...
}: let
  localSecret = "healthchecks/local/ping-key";
  remoteSecret = "healthchecks/remote/ping-key";

  healthchecksBase = {
    endpoint,
    remote ? false,
    sopsSecret ?
      if remote
      then remoteSecret
      else localSecret,
    extra ? "",
  }: ''
    pingKey="$(cat ${config
      .sops
      .secrets
      ."${sopsSecret}"
      .path})"
    ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused --location "${
      if remote
      then "https://hc-ping.com"
      else "http://healthchecks.lan/ping"
    }/$pingKey/${endpoint}?create=1" ${extra}
  '';

  healthchecksPing = {
    slug,
    secret ? localSecret,
  }:
    pkgs.writeShellScript "hc-ping-${slug}"
    (healthchecksBase {
      endpoint = slug;
      sopsSecret = secret;
    });
  healthchecksLog = {
    slug,
    secret ? localSecret,
  }:
    pkgs.writeShellScript "hc-log-${slug}"
    (healthchecksBase {
      endpoint = "${slug}/log";
      sopsSecret = secret;
      extra = ''--data-raw "$1"'';
    });
in {
  getSiteRoot = service: "https://${service}.${config.networking.hostName}.mawz.dev";
  writeHealthchecksPingScript = healthchecksPing;
  writeHealthchecksLogScript = healthchecksLog;
  writeHealthchecksCombinedScript = {
    slug,
    secret ? localSecret,
  } @ params: command:
    pkgs.writeShellScript "hc-combined-${slug}" ''
      set +e
      logs=$(${command} 2>&1)
      code=$?
      set -e

      ${healthchecksLog params} "$logs"

      if [ "$code" -eq "0" ]; then
        ${healthchecksPing params}
      fi
    '';
  writeRemoteHealthchecksPingScript = {
    slug,
    secret ? remoteSecret,
  }:
    pkgs.writeShellScript "remote-hc-ping-${slug}"
    (healthchecksBase {
      endpoint = slug;
      remote = true;
      sopsSecret = secret;
    });
}
