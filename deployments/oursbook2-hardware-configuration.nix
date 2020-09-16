# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Fix acpi warning and disable descete GPU using acpi_call
  # https://wiki.archlinux.org/index.php/Dell_XPS_15_9560#Disable_discrete_GPU
  # https://wiki.archlinux.org/index.php/Hybrid_graphics#Using_acpi_call
  boot.kernelParams = [ "acpi_rev_override=1" "pcie_aspm=off"];
  #boot.extraModulePackages = with config.boot.kernelPackages; [ acpi_call ];
  #systemd.tmpfiles.rules = [ "w /proc/acpi/call - - - - \\\\_SB.PCI0.PEG0.PEGP._OFF" ];
  #boot.extraModprobeConfig = ''
  #    install nouveau /run/current-system/sw/bin/false
  #'';

  # disable card with bbswitch by default since we turn it on only on demand!
  hardware.nvidiaOptimus.disable = true;
  # install nvidia drivers in addition to intel one
  hardware.opengl.extraPackages = [ pkgs.linuxPackages.nvidia_x11.out ];
  hardware.opengl.extraPackages32 = [ pkgs.linuxPackages.nvidia_x11.lib32 ];

  # Needed by Nvidia docker driver
  hardware.opengl.driSupport32Bit = true;


  fileSystems."/" =
    { device = "/dev/disk/by-uuid/8f32a568-5c9a-46c9-bd85-3869d60f6d4b";
      fsType = "ext4";
    };

  boot.initrd.luks.devices =
    {
      "root" = {
        device = "/dev/disk/by-uuid/c3894b66-f79c-465f-b11e-32b78035fa46";
        keyFile = "/dev/disk/by-id/usb-SanDisk_Cruzer_Switch_4C532000061005117093-0:0";
        keyFileSize = 256;
        allowDiscards = true;
        fallbackToPassword = true;
      };
    };
  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/9D78-C770";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/6eb307fd-9aff-4e63-9853-01dd700120d8"; }
    ];

  # Use LTS kernel
  #boot.kernelPackages = pkgs.linuxPackages_4_19;

  # Use latest kernel
  #boot.kernelPackages = pkgs.linuxPackages_latest;

  # Keep me updated
  services.fwupd.enable = true;
  hardware.cpu.intel.updateMicrocode = true;

  # Enable periodic SSD TRIM (default weekly)
  services.fstrim.enable = true;

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
}
