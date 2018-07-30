{ config,
  pkgs ? import ../nixpkgs { },
  lib,
  ...
}:
{
  networking.hostName = "roggy"; # Define your hostname.

  # system.nixos.stateVersion = 18.03;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  imports = [
    ./roggy-hardware-configuration.nix
    ../modules/common.nix
    ../modules/development.nix
    ../modules/graphical.nix
  ];

  environments.mickours.common = {
    enable = true;
    keys = [
      (lib.readFile ./keys/id_rsa_roggy.pub)
      (lib.readFile ./keys/id_rsa_oursbook.pub)
    ];
  };

  environments.mickours.graphical.enable = true;
  environments.mickours.development.enable = true;

  # Make Steam works
  users.users.mmercier.packages = [ pkgs.steam ];
  hardware.opengl.driSupport32Bit = true;
  hardware.pulseaudio.support32Bit = true;

  networking.firewall.enable = false;
}

