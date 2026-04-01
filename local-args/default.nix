{
  pkgs,
  config,
  inputs,
  ...
}: {
  _module.args.local = {
    utils = pkgs.callPackage ./utils.nix {inherit config;};
    secrets = inputs.secrets;
    secret-attrs = import (inputs.secrets + /nix);
  };
}
