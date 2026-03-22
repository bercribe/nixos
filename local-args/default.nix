{
  pkgs,
  config,
  secrets,
  ...
}: {
  _module.args.local = {
    utils = pkgs.callPackage ./utils.nix {inherit config;};
    secrets = secrets;
    secret-attrs = import (secrets + /nix);
  };
}
