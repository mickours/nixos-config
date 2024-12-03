{ lib, pkgs, config, inputs, permittedInsecurePackages, ... }: {
  networking.hostName = "oursbook3";

  system.stateVersion = "24.05";

  # Activate Flakes
  nix.package = pkgs.nixFlakes;
  nix.extraOptions = ''
    experimental-features = nix-command flakes ca-derivations
  '';
  # Add an Acces point for WiFi sharing because gnome Hotspot does not work
  #services.create_ap = {
  #  enable = true;
  #  settings = {
  #    INTERNET_IFACE = "enp44s0u1u4";
  #    WIFI_IFACE = "wlp0s20f3";
  #    SSID = "OursbookAP";
  #    PASSPHRASE = "nounours666";
  #  };
  #};

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

  # Use the latest kernel
  # WARNING this breaks the touchpad click!!!
  # boot.kernelPackages = pkgs.linuxPackages_latest;

  # Needed for OAR in docker
  # systemd.enableUnifiedCgroupHierarchy = false;

  # Use a specific kernel that does not fail with nouveau
  # WARNING: not working, still some issue after suspend (wayland restarts)
  #boot.kernelPackages = pkgs.linuxPackagesFor (pkgs.linux_5_10.override {
  #  argsOverride = rec {
  #    version = "5.10.94";
  #    src = pkgs.fetchurl {
  #          url = "mirror://kernel/linux/kernel/v5.x/linux-${version}.tar.xz";
  #          sha256 = "sha256-KP9Eqkqaih6lKudORI2mF0yk/wQt3CAuNrFXyVHNdQg=";
  #    };
  #    modDirVersion = version;
  #    };
  #});

  # Enable firmware updates
  services.fwupd.enable = true;

  # Microsoft exchange support in evolution
  programs.evolution = {
    enable = true;
    plugins = [ pkgs.evolution-ews ];
  };

  # Add virtualbox and docker
  virtualisation = {
    # virtualbox.host.enable = true;
    libvirtd.enable = true;
    docker.enable = true;
    docker.extraOptions = "--insecure-registry ryax-registry.ryaxns:5000";
    podman.enable = true;
  };

  # Enable cross compilation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  programs.singularity.enable = true;

  # Adroid management (adb, fastboot..)
  programs.adb.enable = true;
  users.users.mmercier.extraGroups = [ "adbusers" ];

  # Add fzf fuzzy coppletion
  #programs.fzf.fuzzyCompletion = true;

  # Share local files wih QR codd
  #programs.sharing.enable = true;

  # Add docker and libvirt users
  users.extraUsers.mmercier.extraGroups = [ "docker" "libvirtd" ];

  # Enable Nvidia proprietary driver
  # WARNING: Requires to activate "Discrete" GPU on the BIOS display setting.
  # Also, Nvidia driver is buggy and does not work properly after suspend.
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia.nvidiaSettings = true;
  hardware.nvidia.powerManagement.enable = true;
  hardware.nvidia.powerManagement.finegrained = false;
  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.package = config.boot.kernelPackages.nvidiaPackages.stable;  # (installs 550)
  hardware.nvidia.prime = {
    offload.enable = true;
    offload.enableOffloadCmd = true;
    # Bus ID of the Intel GPU. You can find it using lspci, either under 3D or VGA
    intelBusId = "PCI:0:2:0";
    # Bus ID of the NVIDIA GPU. You can find it using lspci, either under 3D or VGA
    nvidiaBusId = "PCI:1:0:0";
  };
  # Add docker support
  hardware.nvidia-container-toolkit.enable = true;

  environment.systemPackages =
    with pkgs; [
      lm_sensors
      pass
      wl-clipboard
      gnomeExtensions.gsconnect
      linuxPackages.acpi_call
      zoom-us
      skypeforlinux
      jetbrains.pycharm-community
      jetbrains.webstorm
      vscode-fhs
      go
      pciutils

      libreoffice
      gnome.gnome-boxes
    ];

  # for GSConnect
  networking.firewall.allowedTCPPortRanges = [
    { from = 1714; to = 1764; }
  ];
  networking.firewall.allowedUDPPortRanges = [
    { from = 1714; to = 1764; }
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

  services.logind.extraConfig = ''
    HandlePowerKey=suspend
  '';

  services.fprintd.enable = true;

  # Add personal account
  #users.users.mickours.isSystemUser = true;
  users.extraUsers.mickours = {
    isNormalUser = true;
    extraGroups = [ "wheel" "lp" "networkmanager" "pipewire" ];
  };
}

