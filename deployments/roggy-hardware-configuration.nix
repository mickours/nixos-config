# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usb_storage" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Blacklist nouveau
  boot.extraModprobeConfig = "install nouveau /run/current-system/sw/bin/false";

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/31ba5a29-0da2-43c8-aff1-2ac222281117";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F4A7-1F7C";
      fsType = "vfat";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/0870866b-9ee0-46d1-9ce2-6766879072ca"; }
    ];

  nix.maxJobs = lib.mkDefault 8;
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  hardware.cpu.intel.updateMicrocode = true;

  # Enable periodic SSD TRIM (default weekly)
  services.fstrim.enable = true;
}
