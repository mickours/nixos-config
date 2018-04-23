# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config,
  pkgs ? import ../nixpkgs { },
  ...
}:
let
  mypkgs = import /home/mmercier/Projects/nixpkgs { };

  my_dotfiles = builtins.fetchTarball "https://github.com/mickours/dotfiles/archive/master.tar.gz";
in
rec {
  nix = {
    # make sure dependencies are well defined
    useSandbox = true;

    # build with 3 out of 4 cores
    buildCores = 3;

    # keep build dpendencies to enable offline rebuild
    extraOptions = ''
      gc-keep-outputs = true
      gc-keep-derivations = true
      '';
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      #./config/proxy.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # manage encrypted ROOT partition
  boot.initrd.luks.devices =
  #let
  #  luks_key_name = "aa-luks-key-encrypted";
  #  luks_key = "/dev/mapper/${luks_key_name}";
  #in
  [
    #{
    #  name = luks_key_name;
    #  device = "/luks-key.img";
    #}
    {
      name = "root";
      device = "/dev/disk/by-uuid/c3a6ae03-368b-4877-b8a3-9d02c0a64d47";
      keyFile = "/dev/disk/by-id/usb-SanDisk_Cruzer_Switch_4C532000061005117093-0:0";
      keyFileSize = 256;
      preLVM = true;
      allowDiscards = true;
    }
    {
      name = "home";
      device = "/dev/disk/by-uuid/edea857a-8e93-4eaf-b7cd-e94b753cd573";
      keyFile = "/dev/disk/by-id/usb-SanDisk_Cruzer_Switch_4C532000061005117093-0:0";
      keyFileSize = 256;
      preLVM = true;
      allowDiscards = true;
    }
  ];

  # Use LTS kernel
  boot.kernelPackages = pkgs.linuxPackages_4_9;

  networking.hostName = "oursbook"; # Define your hostname.

  # Select internationalisation properties.
  i18n = {
    consoleKeyMap = "fr";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  # NOTE: Use NTP instead
  #time.timeZone = "Europe/Paris";

  # Add virtualbox and docker
  virtualisation = {
    virtualbox.host.enable = true;
    docker.enable = true;
  };

  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    ## Nix related
    nox
    nix-repl
    nix-prefetch-scripts
    nix-zsh-completions

    ## install nix-home
    #((pkgs.callPackage ./pkgs/nix-home.nix) {})

    ## Admin tools
    # Storage
    ntfs3g
    exfat
    parted
    hdparm
    linuxPackages.perf
    # Monitoring
    psmisc
    pmutils
    nmap
    htop
    usbutils
    iotop
    stress
    tcpdump
    # Files
    file
    tree
    ncdu
    unzip
    unrar
    # Shell
    zsh
    tmux
    ranger
    # ranger previews
    libcaca   # video
    highlight # code
    atool     # archives
    w3m       # web
    poppler   # PDF
    mediainfo # audio and video
    # Password
    gnupg
    (mypkgs.pass.override { tombPluginSupport = true; })
    # Misc
    cloc
    jq
    qemu

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
    # Mail
    gnome3.evolution
    aspellDicts.fr
    aspellDicts.en
    # Message
    qtox
    skype
    tdesktop
    gnome3.polari
    liferea
    # Media
    vlc
    # Utils
    gnome3.gnome-disk-utility
    xorg.xkill
    wireshark-gtk

    ## Development environment
    gitAndTools.gitFull
    git-cola
    gitg
    python3
    python2
    gcc
    ctags
    gnumake
    wget
    cmake
    gdb
    # Editors
    emacs
    qtcreator
    neovim
    (callPackage ./my_vim.nix { my_vim_config= builtins.readFile("${my_dotfiles}/vimrc"); })
    # Web Site
    hugo
    # Graphic tools
    gcolor3
    graphviz
    imagemagick
    inkscape
    # Text/Tex/PDF
    entr
    pandoc
    rubber
    texlive.combined.scheme-small

    ## Pro
    cntlm
    opensc
    libreoffice
    zotero

    ## Backups and sync
    python27Packages.syncthing-gtk
    transmission_gtk

    ## Printers
    saneBackends
    samsungUnifiedLinuxDriver

    ## Fun
    fortune
    sl
    wesnoth-dev
  ];

  environment.gnome3.excludePackages = [
    # gnome-software doesn't build and it wouldn't work with nixos anyway, at
    # least before something like this is done:
    # RFC: Generating AppStream Metadata #15932:
    # https://github.com/NixOS/nixpkgs/issues/15932
    pkgs.gnome3.gnome-software
  ];

  # use Vim by default
  environment.sessionVariables.EDITOR="v";
  environment.sessionVariables.VISUAL="v";
  environment.shellAliases = {
    "vim"="v";
    };

  # Add Workaround for USB 3 Scanner for SANE
  # See http://sane-project.org/ Note 3
  environment.variables.SANE_USB_WORKAROUND = "1";

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  services = {
    # Install but disable open SSH
    openssh = {
      enable = false;
      permitRootLogin = "false";
    };

    # Network time
    # Made by systemd time-sync daemon now
    #ntp = {
    #  enable = true;
    #  servers = [ "server.local" "0.pool.ntp.org" "1.pool.ntp.org" "2.pool.ntp.org" ];
    #};

    # Enable CUPS to print documents.
    printing = {
      enable = true;
      browsing = true;
      clientConf = ''
        ServerName print.imag.fr:631
      '';
      drivers = [ pkgs.samsung-unified-linux-driver ];
    };
    # Needed for printer discovery
    avahi.enable = true;
    avahi.nssmdns = true;

    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      layout = "fr";
      xkbOptions = "eurosign:e";
      libinput.enable = true;

      # Enable the Gnome Desktop Environment.
      desktopManager.gnome3.enable = true;
      #desktopManager.plasma5.enable = true;

      displayManager.gdm.enable = true;
    };

    syncthing = {
      enable = true;
      user = "mmercier";
      group = "mmercier";
      dataDir = /home/mmercier/.config/syncthing;
      systemService = false;
    };
  };

  # Make fonts better...
  fonts.fontconfig = {
    enable = true;
    ultimate.enable = true;
  };

  fonts.fonts = [ pkgs.corefonts ];

  programs = {
    # Enable system wide zsh and ssh agent
    zsh.enable = true;
    ssh.startAgent = true;

    bash = {
      enableCompletion = true;
      # Make shell history shared and saved at each command
      interactiveShellInit = ''
        shopt -s histappend
        PROMPT_COMMAND="history -n; history -a"
        unset HISTFILESIZE
        HISTSIZE=5000
        '';
      };
    # Whether interactive shells should show which Nix package (if any)
    # provides a missing command.
    command-not-found.enable = true;
  };

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.mmercier = {
    description = "Michael Mercier";
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" "lp" "networkmanager" "vboxusers" "docker" "gdm" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXXsbhzexlZS+hCRS39cEo3BOZTLGtO8mKUE6U0gwDRNE0hE/H4Nr9Gn9NGxmmWFdTZmuaU85Z66ofe4C9Hz8pgRzB8b4Ids3XXzdeud5+znN7tKERt9Qi7a25q8vKTYlftcOIvT+6v4YVmih/NoLx5Dw9+B2tS0E20VY0skbL4s7TYmrXIrSPz6dX/JpjivF90eJSc0pVkT8ZSbZV2fygRW7JbgN490iJ+sRGnwfDjpYA7yQjyrpDJifXwdXg/NnilW6WnwbKBNXcjTIsVg1PEffZIJKAEOZzl/txNKU2kjYAZTtBGqJ491md+T3ptjvcNehia5if3GGbjm7xalzsRwOVmMisfQT4KP/cyZ66fxbU8qMgzspCjvCpEPXRQH2Q4jVWZkx2iulmB2wNbXaxs58ueelMJMO3gpZ2xBYwah7QSZK2nHG44dKfC6OAGcah7FI5+dplzwBtROWvPxkiSWJbBcxymcY5QkValWJeavC7gwDhC/zjNfa+oKRLYSsgoiiD0BRcvm+UisyGZ59C3T0lJTZpnn63RwY4WvVQzh1ltdqckZMFwaqn0ywIA9+JCD2u9P8STiRpcXq+kQnEMPYUIXRGm8KFXkdB08j8uNC0F+EF7oqgWTpGv8xVJnic48V49Vp9DDIK4BCuqgViwBMBaIqosX3j9E8JzWuAnQ== mercierm@oursbook"];
  };

  # Smart card
  services.pcscd.enable = true;

  nixpkgs.config.firefox.enableAdobeFlash = true;

  # every machine should be running antivirus
  services.clamav.updater.enable = true;

  # Enable browserpass to access pass within Firefox
  #programs.browserpass.enable = true;
  #programs.gnupg.agent.enableBrowserSocket = true;
  #programs.gnupg.agent.enable = true;

  # enable thefuck!
  programs.thefuck.enable = false;

  # enable cron table
  services.cron.enable = true;

  security.sudo.extraConfig = ''
    Defaults   insults
    '';

  nixpkgs.config.packageOverrides = pkgs:
  {

    sudo = pkgs.sudo.override { withInsults = true; };

    #saneBackends = pkgs.saneBackends.overrideAttrs (oldAttrs: {
    #  src = pkgs.fetchurl {
    #    url = "http://pkgs.fedoraproject.org/repo/pkgs/sane-backends/sane-backends-1.0.23.tar.gz/e226a89c54173efea80e91e9a5eb6573/sane-backends-1.0.23.tar.gz";
    #    sha256 = "0adhrdih20g45xwky3z4h2g78fk2vkkxspyp1vygfnk1h4l5nksd";
    #  };
    #});
  };

  # Try fix chrome extension error
  services.dbus.socketActivated = true;
  services.xserver.desktopManager.gnome3.sessionPath = [
    pkgs.json_glib
    pkgs.glib_networking
    pkgs.libgtop ];
}

