{ config, lib, pkgs, ... }: {
  networking.hostName = "oursbook3";

  system.stateVersion = "21.11";

  # Activate Flakes
  nix.package = pkgs.nixUnstable;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  imports = [
    ./oursbook3-hardware-configuration.nix
    ../modules/common.nix
    ../modules/development.nix
    ../modules/graphical.nix
  ];

  environments.mickours.common = {
    enable = true;
    keyFiles = [ ];
  };

  environments.mickours.graphical.enable = true;
  environments.mickours.graphical.myuser = "mmercier";
  environments.mickours.development.enable = true;

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use swap only if needed
  boot.kernel.sysctl = { "vm.swappiness" = 10; };

  # Add virtualbox and docker
  virtualisation = {
    # virtualbox.host.enable = true;
    # libvirtd.enable = true;
    docker.enable = true;
    docker.extraOptions = "--insecure-registry ryax-registry.ryaxns:5000";
    # docker.enableNvidia = true;
  };

  programs.singularity.enable = true;

  # Adroid management (adb, fastboot..)
  programs.adb.enable = true;
  users.users.mmercier.extraGroups = ["adbusers"];

  # Add docker and libvirt users
  users.extraUsers.mmercier.extraGroups = [ "docker" "libvirtd" ];

  # Enable Nvidia Prime
  #services.xserver.videoDrivers = [ "nvidia" ];
  #hardware.nvidia.prime = {
  #  offload.enable = true;

  #  # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
  #  intelBusId = "PCI:0:2:0";

  #  # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
  #  nvidiaBusId = "PCI:1:0:0";
  #};
  services.xserver.libinput.enable = true;

  environment.systemPackages = let
  #nvidia-offload = pkgs.writeShellScriptBin "nvidia-offload" ''
  #  export __NV_PRIME_RENDER_OFFLOAD=1
  #  export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
  #  export __GLX_VENDOR_LIBRARY_NAME=nvidia
  #  export __VK_LAYER_NV_optimus=NVIDIA_only
  #  exec -a "$0" "$@"
  #'';
  in with pkgs; [
    # nvidia-offload
    lm_sensors
    pass
    wl-clipboard
    gnomeExtensions.gsconnect
    linuxPackages.acpi_call
    zoom-us
    skype
    jetbrains.pycharm-community
    jetbrains.webstorm
    pciutils

    libreoffice
  ];

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

  # Add personal account
  #users.users.mickours.isSystemUser = true;
  users.extraUsers.mickours = {
    isNormalUser = true;
    extraGroups = [ "wheel" "lp" "networkmanager" ];
  };
}

