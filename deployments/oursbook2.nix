{ config,
  pkgs ? import ../nixpkgs { },
  lib,
  ...
}:
rec {
  networking.hostName = "oursbook2";

  system.stateVersion = "19.09";

  nix.nixPath = [
        "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs"
        "nixos-config=/etc/nixos/configuration.nix"
        "/nix/var/nix/profiles/per-user/root/channels"
        "kapack=${builtins.toPath /home/mmercier/Projects/kapack}"
  ];

  imports = [
    ./oursbook2-hardware-configuration.nix
    ../modules/common.nix
    ../modules/development.nix
    ../modules/graphical.nix
  ];

  environments.mickours.common = {
    enable = true;
    keyFiles = [
      ./keys/id_rsa_oursbook.pub
      ./keys/id_rsa_roggy.pub
    ];
  };

  environments.mickours.graphical.enable = true;
  environments.mickours.graphical.myuser = "mmercier";
  environments.mickours.development.enable = true;

 # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Add virtualbox and docker
  virtualisation = {
    virtualbox.host.enable = true;
    docker.enable = true;
    docker.extraOptions = "--insecure-registry registry.ryax.local:80";
    docker.enableNvidia = true;
    libvirtd.enable = true;
  };

  # Add docker and libvirt users
  users.extraUsers.mmercier.extraGroups = [ "docker" "libvirtd" ];

  environment.systemPackages = with pkgs; [
    lm_sensors
    pass
    gnomeExtensions.gsconnect
    linuxPackages.acpi_call
    zoom-us
    pulseeffects

    #libreoffice
    zotero
    gnome3.pomodoro
  ];

  # Ryax related
  services.zerotierone = {
      enable = true;
      joinNetworks = ["8267aa80ea375ab2"]; # One of these has a managed route
    };

  networking.firewall.enable = false;
  networking.extraHosts =
  ''
    127.0.0.1 ryax.local api.ryax.local registry.ryax.local monitor.ryax.local
  '';
  #security.pki.certificateFiles = [ /home/mmercier/certs/domain.crt ];

  systemd.services.vpc-backups = rec {
    description = "Backup my vpc (${startAt})";
    startAt = "daily";

    serviceConfig = {
      User = "mmercier";
      ExecStart = "/run/current-system/sw/bin/rsync -avz vpc:/data /home/mmercier/Backups/vpc";
    };
  };
}

