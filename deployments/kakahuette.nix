# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./kakahuette-hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "kakahuette"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Select internationalisation properties.
  i18n = {
    #consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "fr";
    defaultLocale = "fr_FR.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  nixpkgs.config.allowUnfree = true;

  # Make fonts better...
  fonts.fontconfig = {
    enable = true;
    ultimate.enable = true;
  };

  fonts.fonts = [ 
    pkgs.corefonts
    pkgs.dejavu_fonts
    pkgs.andagii
    pkgs.anonymousPro
    pkgs.arkpandora_ttf
    pkgs.bakoma_ttf
    pkgs.cantarell_fonts
    pkgs.corefonts
    pkgs.clearlyU
    pkgs.cm_unicode
    pkgs.freefont_ttf
    pkgs.gentium
    pkgs.inconsolata
    pkgs.liberation_ttf
    pkgs.libertine
    pkgs.lmodern
    pkgs.mph_2b_damase
    pkgs.oldstandard
    pkgs.theano
    pkgs.tempora_lgc
    pkgs.terminus_font
    pkgs.ttf_bitstream_vera
    pkgs.ucsFonts
    pkgs.unifont
    pkgs.vistafonts
    pkgs.wqy_zenhei
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    wget vim
     ## Graphical environment
    # Gnome stuff
    # For system Monitor plugin
    gobjectIntrospection
    libgtop
    json_glib
    glib_networking
    # Fix Gnome crash
    gnome3.gjs
    # Web
    firefox
    chrome-gnome-shell
    flashplayer
    aspellDicts.fr
    aspellDicts.en
    # Message
    skype
    # Media
    vlc
    # Utils
    gnome3.gnome-disk-utility
    xorg.xkill
    # Storage
    ntfs3g
    exfat
    mtpfs
    # Pro
    libreoffice-fresh
    gimp
    ## Backups and sync
    python27Packages.syncthing-gtk
    transmission_gtk
    ## Printers
    saneBackends
    samsungUnifiedLinuxDriver
    ## Enable numock by default
    numlockx
    ## Games
    gnome3.aisleriot
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs.bash.enableCompletion = true;
  # programs.mtr.enable = true;
  # programs.gnupg.agent = { enable = true; enableSSHSupport = true; };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
  # every machine should be running antivirus
  services.clamav.updater.enable = true;

  # Enable CUPS to print documents.
  services.printing.enable = true;

  services.printing.browsing = true;
  services.printing.drivers = [ pkgs.samsung-unified-linux-driver ];
  # Needed for printer discovery
  services.avahi.enable = true;

  services.syncthing = {
      enable = true;
      user = "marine";
      group = "marine";
      dataDir = /home/marine/.config/syncthing;
      systemService = false;
    };

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Enable the X11 windowing system.
  services.xserver.enable = true;
  services.xserver.layout = "fr";
  services.xserver.xkbOptions = "eurosign:e";
  services.xserver.enableCtrlAltBackspace = true;

  # Enable touchpad support.
  services.xserver.libinput.enable = true;

  # Enable the Desktop Environment.
  services.xserver.desktopManager.gnome3.enable = true;
  services.xserver.displayManager.gdm.enable = true;

  # System monitor gnome extension dependencies
  services.xserver.desktopManager.gnome3.sessionPath = [
    pkgs.json_glib
    pkgs.glib_networking
    pkgs.libgtop ];

  # Give an hit when program not found
  programs.command-not-found.enable = true;

  nixpkgs.config.firefox.enableAdobeFlash = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.marine = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "lp" "gdm" ]; 
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.mmercier = {
    description = "Michael Mercier";
    uid = 1001;
    isNormalUser = true;
    extraGroups = [ "wheel" "lp" "gdm" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXXsbhzexlZS+hCRS39cEo3BOZTLGtO8mKUE6U0gwDRNE0hE/H4Nr9Gn9NGxmmWFdTZmuaU85Z66ofe4C9Hz8pgRzB8b4Ids3XXzdeud5+znN7tKERt9Qi7a25q8vKTYlftcOIvT+6v4YVmih/NoLx5Dw9+B2tS0E20VY0skbL4s7TYmrXIrSPz6dX/JpjivF90eJSc0pVkT8ZSbZV2fygRW7JbgN490iJ+sRGnwfDjpYA7yQjyrpDJifXwdXg/NnilW6WnwbKBNXcjTIsVg1PEffZIJKAEOZzl/txNKU2kjYAZTtBGqJ491md+T3ptjvcNehia5if3GGbjm7xalzsRwOVmMisfQT4KP/cyZ66fxbU8qMgzspCjvCpEPXRQH2Q4jVWZkx2iulmB2wNbXaxs58ueelMJMO3gpZ2xBYwah7QSZK2nHG44dKfC6OAGcah7FI5+dplzwBtROWvPxkiSWJbBcxymcY5QkValWJeavC7gwDhC/zjNfa+oKRLYSsgoiiD0BRcvm+UisyGZ59C3T0lJTZpnn63RwY4WvVQzh1ltdqckZMFwaqn0ywIA9+JCD2u9P8STiRpcXq+kQnEMPYUIXRGm8KFXkdB08j8uNC0F+EF7oqgWTpGv8xVJnic48V49Vp9DDIK4BCuqgViwBMBaIqosX3j9E8JzWuAnQ== mercierm@oursbook"];
};

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?

}
