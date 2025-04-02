{
  imports = [../../modules/systems/hardware/disko-base.nix];

  local.disko = {
    device = "/dev/disk/by-id/ata-GOFATOO_256GB_SSD_0000000000010000066";
    spaceReserved = "40G";
    extraRootDatasets = ["services"];
  };
}
