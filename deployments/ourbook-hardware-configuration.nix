# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports = [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix> ];

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "rtsx_pci_sdmmc"
  ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  # boot.cleanTmpDir = true;
  # boot.tmpOnTmpfs = true;

  # Activate proprietary drivers for graphic card
  #services.xserver.videoDrivers = [ "ati_unfree" ];

  # Blacklist radeon and amdgpu
  boot.extraModprobeConfig = ''
    install radeon /run/current-system/sw/bin/false
    install amdgpu /run/current-system/sw/bin/false
  '';

  # Not working on old kernel
  #boot.kernelParams = [
  #  # Enable Multi queue IO scheduler
  #  "scsi_mod.use_blk_mq=1"
  #];

  # Set the multiqueue scheduler depending on if it is an HDD or an SSD
  services.udev.extraRules = ''
    # set scheduler for non-rotating disks
    ACTION=="add|change", KERNEL=="sd[a-z]|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="deadline"
    # set scheduler for rotating disks
    ACTION=="add|change", KERNEL=="sd[a-z]", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="cfq"
  '';

  # Enable periodic SSD TRIM (default weekly)
  services.fstrim.enable = true;

  fileSystems."/" = {
    device = "/dev/disk/by-uuid/f7860309-bc61-4906-814f-790c76f62eac";
    fsType = "ext4";
    options = [ "noatime" "barrier=0" ];
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/BE57-9003";
    fsType = "vfat";
  };

  fileSystems."/home" = {
    device = "/dev/disk/by-uuid/fd02b73b-9bbd-4387-9998-cafed922169a";
    fsType = "ext4";
    options = [ "noatime" "barrier=0" ];
  };

  swapDevices =
    [{ device = "/dev/disk/by-uuid/2253a85e-99ee-44a8-bf9b-569f028e2d76"; }];

  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = "powersave";

  hardware.cpu.intel.updateMicrocode = true;
}
