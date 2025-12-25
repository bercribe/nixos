{lib, ...}: {
  options.local.constants.hosts = with lib;
  with types;
    mkOption {
      type = attrsOf str;
    };

  config.local.constants.hosts = {
    echoes = "echoes";
    heavens-door = "heavens-door";
    highway-star = "highway-star";
    judgement = "judgement";
    moody-blues = "moody-blues";
    super-fly = "super-fly";
  };
}
