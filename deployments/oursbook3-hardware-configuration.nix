# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "aesni_intel" "cryptd" ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  # Avoid touchpad click to tap (clickpad) bug. For more details see:
  # https://wiki.archlinux.org/title/Touchpad_Synaptics#Touchpad_does_not_work_after_resuming_from_hibernate/suspend
  boot.kernelParams = [ "psmouse.synaptics_intertouch=0" ];
  boot.extraModulePackages = [ ];
  # boot.blacklistedKernelModules = [ "nouveau" ];

  # Avoid WiFi stall and Hotspot errors
  boot.extraModprobeConfig = ''
    options iwlwifi 11n_disable=1
    options iwlwifi wd_disable=0
  '';
  #options iwlwifi bt_coex_active=0

  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/0a73544f-6095-43fa-a61c-6e48ce861906";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/3780-0E0D";
      fsType = "vfat";
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-uuid/f10e14e4-b928-4607-adb4-36f1e963dae8";
      fsType = "ext4";
    };

  swapDevices = [{
    device = "/swapfile";
    size = (1024 * 16); # RAM size = 16 G
  }];

  boot.initrd.luks.devices = {
    "crypted".device = "/dev/disk/by-uuid/38f1c94c-5dfa-4e0a-8ec0-ae78126ac3c0";
    "cryptedHome".device = "/dev/disk/by-uuid/49de7905-4a45-4333-8b3a-b9ee9a71ef25";
  };

  #powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  hardware.trackpoint.device = "TPPS/2 Elan TrackPoint";
}
