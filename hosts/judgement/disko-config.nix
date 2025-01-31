{
  imports = [../../modules/systems/hardware/disko-base.nix];

  local.disko = {
    device = "/dev/disk/by-id/nvme-Lexar_SSD_NM7A1_1TB_NJB5822002994P2200";
    zpoolName = "zpool";
    makeVarDataset = true;
    makeServicesDataset = true;
    spaceReserved = "150G";
  };
}
