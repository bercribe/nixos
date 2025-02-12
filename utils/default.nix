{
  pkgs,
  config,
  ...
}: let
  healthchecksBase = ''
    pingKey="$(cat ${config.sops.secrets."healthchecks/local/ping-key".path})"
    ${pkgs.curl}/bin/curl -m 10 --retry 5 --retry-connrefused "http://healthchecks.lan/ping/$pingKey/'';
in {
  writeHealthchecksPingScript = slug:
    pkgs.writeShellScript "hc-ping-${slug}" ''
      ${healthchecksBase}${slug}"
    '';
  writeHealthchecksLogScript = slug:
    pkgs.writeShellScript "hc-log-${slug}" ''
      ${healthchecksBase}${slug}/log" --data-raw "$1"
    '';
}
