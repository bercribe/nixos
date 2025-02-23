{
  pkgs,
  config,
  ...
}: {
  imports = [./common.nix];

  services.xserver.videoDrivers = ["amdgpu"];
}
