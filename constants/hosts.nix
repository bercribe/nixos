{
  lib,
  local,
  ...
}: {
  options.local.constants.hosts = with lib;
  with types;
    mkOption {
      type = attrsOf (submodule {
        options = {
          domain = mkOption {
            type = str;
            default = "mawz.dev";
            description = "DNS base name for host";
          };
        };
      });
    };

  config.local.constants.hosts = {
    echoes = {
      domain = local.secrets.personal-domain;
    };
    heavens-door = {};
    hermit-purple = {};
    hierophant-green = {};
    highway-star = {};
    judgement = {};
    lovers = {};
    moody-blues = {};
    mr-president = {};
    notorious-big = {};
    super-fly = {};
  };
}
