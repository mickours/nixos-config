{ config, pkgs ? import ../nixpkgs { }, lib, ... }:
let
  my_dotfiles = builtins.fetchTarball
    "https://github.com/mickours/dotfiles/archive/master.tar.gz";
in rec {
  networking.hostName = "oursbook";

  system.stateVersion = 19.03;

  nix.nixPath = [
    "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs"
    "nixos-config=/etc/nixos/configuration.nix"
    "/nix/var/nix/profiles/per-user/root/channels"
    "kapack=${builtins.toPath /home/mmercier/Projects/kapack}"
  ];

  imports = [
    ./ourbook-hardware-configuration.nix
    ../modules/common.nix
    ../modules/development.nix
    ../modules/graphical.nix
  ];

  environments.mickours.common = {
    enable = true;
    keyFiles = [ ./keys/id_rsa_oursbook.pub ./keys/id_rsa_roggy.pub ];
  };

  environments.mickours.graphical.enable = true;
  environments.mickours.graphical.myuser = "mmercier";
  environments.mickours.development.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # manage encrypted ROOT partition
  boot.initrd.luks.devices = [
    {
      name = "root";
      device = "/dev/disk/by-uuid/c3a6ae03-368b-4877-b8a3-9d02c0a64d47";
      keyFile =
        "/dev/disk/by-id/usb-SanDisk_Cruzer_Switch_4C532000061005117093-0:0";
      keyFileSize = 256;
      preLVM = true;
      allowDiscards = true;
      fallbackToPassword = true;
    }
    {
      name = "home";
      device = "/dev/disk/by-uuid/edea857a-8e93-4eaf-b7cd-e94b753cd573";
      keyFile =
        "/dev/disk/by-id/usb-SanDisk_Cruzer_Switch_4C532000061005117093-0:0";
      keyFileSize = 256;
      preLVM = true;
      allowDiscards = true;
      fallbackToPassword = true;
    }
  ];

  # Use LTS kernel
  # boot.kernelPackages = pkgs.linuxPackages_4_9;

  # Add virtualbox and docker
  virtualisation = {
    virtualbox.host.enable = true;
    docker.enable = true;
    docker.extraOptions = "--insecure-registry registry.myryax.minikube:80";
    libvirtd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    (pass.withExtensions (ext: [ ext.pass-tomb ]))
    skype
    gnomeExtensions.gsconnect

    #libreoffice
    zotero
    gnome3.pomodoro
  ];

  networking.firewall.enable = false;
  networking.extraHosts = ''
    192.168.39.206 myryax.minikube
    192.168.39.206 api.myryax.minikube
    192.168.39.206 registry.myryax.minikube
  '';

  # Add docker and libvirt
  users.extraUsers.mmercier.extraGroups = [ "docker" "libvirtd" ];

  # nixpkgs.config.firefox.enableAdobeFlash = true;
}

