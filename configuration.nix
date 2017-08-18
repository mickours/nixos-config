# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # manage encrypted partition
  boot.initrd.luks.devices = [
    { name = "root";
      device = "/dev/disk/by-uuid/c3a6ae03-368b-4877-b8a3-9d02c0a64d47";
      preLVM = true;
      allowDiscards = true;
    }
  ];
  networking.hostName = "oursbook"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n = {
    # consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "fr";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  nixpkgs.config.allowUnfree = true;

  # Add virtualbox
  virtualisation = {
    virtualbox.host.enable = true;
    docker.enable = true;
  }

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    # Nix related
    nox
    polipo
    # Console environment
    vim
    tmux
    ranger
    pmutils
    git
    nmap
    unzip
    python3
    python2
    htop
    tree
    pass
    ## Graphical environment
    libreoffice
    transmission_gtk
    gitg
    firefox
    gnome3.evolution
    # Development environment
    gcc
    ctags
    gnumake
    wget
  ];


  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  networking.firewall.enable = false;

  services = {
    # Install but disable open SSH
    openssh = {
      enable = false;
      # permitRootLogin = "yes";
    };

    # Enable CUPS to print documents.
    printing = {
      enable = true;
      browsedConf = ''
        BrowsePoll print.imag.fr:631
      '';
    };

    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      layout = "fr";
      xkbOptions = "eurosign:e";
      # Enable the Gnome Desktop Environment.
      desktopManager.gnome3 = true;
    };

  };

  # Make fonts better...
  #fonts = {
  #  enableFontDir = true;
  #  enableGhostscriptFonts = true;
  #  fonts = with pkgs; [
  #    corefonts
  #    inconsolata
  #    ubuntu_font_family
  #    liberation_ttf
  #    unifont
  #    fira
  #  ];
  #};

  # Networking configuration
  service.polipo.enable = true;
  networking.proxy.default = "http://127.0.0.1:8123"
  # TODO add an other polipo conf with parent proxy "http://193.56.47.8:8080";

  # Enable system wide zsh and ssh agent
  programs = {
    zsh.enable = true;
    ssh.startAgent = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.mmercier = {
    description = "Michael Mercier";
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" "lp" ];
    shell = "/run/current-system/sw/bin/zsh";
    openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXXsbhzexlZS+hCRS39cEo3BOZTLGtO8mKUE6U0gwDRNE0hE/H4Nr9Gn9NGxmmWFdTZmuaU85Z66ofe4C9Hz8pgRzB8b4Ids3XXzdeud5+znN7tKERt9Qi7a25q8vKTYlftcOIvT+6v4YVmih/NoLx5Dw9+B2tS0E20VY0skbL4s7TYmrXIrSPz6dX/JpjivF90eJSc0pVkT8ZSbZV2fygRW7JbgN490iJ+sRGnwfDjpYA7yQjyrpDJifXwdXg/NnilW6WnwbKBNXcjTIsVg1PEffZIJKAEOZzl/txNKU2kjYAZTtBGqJ491md+T3ptjvcNehia5if3GGbjm7xalzsRwOVmMisfQT4KP/cyZ66fxbU8qMgzspCjvCpEPXRQH2Q4jVWZkx2iulmB2wNbXaxs58ueelMJMO3gpZ2xBYwah7QSZK2nHG44dKfC6OAGcah7FI5+dplzwBtROWvPxkiSWJbBcxymcY5QkValWJeavC7gwDhC/zjNfa+oKRLYSsgoiiD0BRcvm+UisyGZ59C3T0lJTZpnn63RwY4WvVQzh1ltdqckZMFwaqn0ywIA9+JCD2u9P8STiRpcXq+kQnEMPYUIXRGm8KFXkdB08j8uNC0F+EF7oqgWTpGv8xVJnic48V49Vp9DDIK4BCuqgViwBMBaIqosX3j9E8JzWuAnQ== mercierm@oursbook"];
  };

  # The NixOS release to be compatible with for stateful data such as databases.
  system.stateVersion = "17.03";

}
