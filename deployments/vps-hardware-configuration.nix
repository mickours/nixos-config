{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/profiles/qemu-guest.nix") ];

  boot.initrd.availableKernelModules =
    [ "ata_piix" "uhci_hcd" "ehci_pci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.kernelModules = [ ];
  boot.extraModulePackages = [ ];

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/9f621627-b056-48b9-bac4-2622b6a0df7b";
    fsType = "ext4";
  };

  swapDevices = [{
    device = "/var/swapfile";
    size = 2048;
  }];

  nix.settings.max-jobs = lib.mkDefault 1;
}

