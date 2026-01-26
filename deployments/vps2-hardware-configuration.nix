{ modulesPath, ... }:
{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];
  boot.loader = {
    efi.efiSysMountPoint = "/boot/efi";
    grub = {
      efiSupport = true;
      efiInstallAsRemovable = true;
      device = "nodev";
    };
  };

  boot.kernelParams = [ "console=ttyS0" ];

  fileSystems."/boot/efi" = {
    device = "/dev/disk/by-uuid/7B32-47D9";
    fsType = "vfat";
  };
  boot.initrd.availableKernelModules = [
    "ata_piix"
    "uhci_hcd"
    "xen_blkfront"
    "vmw_pvscsi"
  ];
  boot.initrd.kernelModules = [ "nvme" ];
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };
  fileSystems."/data" = {
    device = "/dev/sda";
    fsType = "ext4";
  };
  zramSwap = {
    enable = true;
    algorithm = "zstd";
    memoryPercent = 30;
  };

  # swapDevices = [
  #   {
  #     device = "/dev/zram0";
  #     # size = 983;
  #   }
  # ];
}
