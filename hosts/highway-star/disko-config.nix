{
  imports = [../../modules/systems/hardware/disko-base.nix];

  local.disko = {
    device = "/dev/disk/by-id/nvme-WDS100T3X0C-00SJG0_21173E800402";
    enableEncryption = true;
    spaceReserved = "150G";
    extraRootDatasets = ["games"];
  };
}
