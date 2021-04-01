{ config, lib, pkgs, ... }: {
  networking.hostName = "oursbook2";

  system.stateVersion = "20.09";

  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  # Activate Flakes
  # nix.package = pkgs.nixUnstable;
  # nix.extraOptions = ''
  #   experimental-features = nix-command flakes
  # '';

  imports = [
    ./oursbook2-hardware-configuration.nix
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

  # Add virtualbox and docker
  virtualisation = {
    virtualbox.host.enable = true;
    docker.enable = true;
    docker.extraOptions = "--insecure-registry registry.ryax.local:80";
    docker.enableNvidia = true;
    libvirtd.enable = true;
  };

  programs.singularity.enable = true;

  # Adroid management (adb, fastboot..)
  programs.adb.enable = true;
  users.users.mmercier.extraGroups = ["adbusers"];

  # Add docker and libvirt users
  users.extraUsers.mmercier.extraGroups = [ "docker" "libvirtd" ];

  # Enable Nvidia Prime
  services.xserver.videoDrivers = [ "modesetting" "nvidia" ];
  hardware.nvidia.prime = {
    offload.enable = true;

    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";

    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };

  environment.systemPackages = let
  nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
    export __NV_PRIME_RENDER_OFFLOAD=1
    export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export __VK_LAYER_NV_optimus=NVIDIA_only
    exec -a "$0" "$@"
  '';
  in with pkgs; [
    nvidia-offload
    lm_sensors
    pass
    gnomeExtensions.gsconnect
    linuxPackages.acpi_call
    zoom-us
    pulseeffects
    citrix_workspace

    #libreoffice
    zotero
    gnome3.pomodoro
  ];

  # Ryax related
  services.zerotierone = {
    enable = true;
    joinNetworks = [ "8267aa80ea375ab2" ]; # One of these has a managed route
  };

  networking.firewall.enable = false;
  networking.extraHosts = ''
    127.0.0.1 ryax.local api.ryax.local registry.ryax.local monitor.ryax.local
  '';
  #security.pki.certificateFiles = [ /home/mmercier/certs/domain.crt ];

  systemd.services.vpc-backups = rec {
    description = "Backup my vpc (${startAt})";
    startAt = "daily";
    path = [ pkgs.openssh pkgs.rsync ];

    serviceConfig = {
      User = "mmercier";
      Group = "users";
      ExecStart = ''
        ${pkgs.rsync}/bin/rsync --rsync-path=/run/current-system/sw/bin/rsync -e"ssh -v -o StrictHostKeyChecking=no" -avz root@vps:/data /home/mmercier/Backups/vpc'';
    };
  };
}

