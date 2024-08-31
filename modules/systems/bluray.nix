# makes usb blue-ray drive work
{config, ...}: {
  boot.kernelModules = ["sg"];
}
