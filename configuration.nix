{ config, pkgs, ... }:
{
  # Boot information

  # imports = [./hardware-configuration.nix];

  # boot on /dev/sda on nixos labeled fylesystem
  boot.loader.grub.device = "/dev/sda";
  fileSystems = [
    { mountPoint = "/";
      label = "nixos";
    }
  ];

  time.timeZone = "Europe/Paris";

  networking = {
    hostName = "nixours"; # Define your hostname.
    networkmanager.enable = true;
  };

  # Select internationalisation properties.
  i18n = {
    consoleKeyMap = "fr";
    defaultLocale = "us_US.UTF-8";
  };

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    # Nix related
    nox
    # Console environment
    pmutils
    nmap
    pandoc
    graphviz
    highlight
    rubber
    pwgen
    git
    unzip
    tmux
    ranger
    python3
    python2
    autossh
    gawk
    htop
    imagemagick
    tree
    ## Graphical environment
    #libreoffice
    #transmission_gtk
    #gitg
    #firefox
    #gnome3
    # Development environment
    gcc gnumake
  ];

  services = {
    openssh = {
      enable = true;
      permitRootLogin = "yes";
    };

    # printing = {
    #     enable = true;
    #     browsedConf = ''
    #     BrowsePoll print.imag.fr:631

    #     '';
    # };

    # xserver = {
    #   enable = true;
    #   layout = "fr";
    #   desktopManager.gnome3 = true;
    # };
  };

  #set password with ‘passwd’.
  users.extraUsers.mercierm = {
    initialHashedPassword = "$6$38Cus8EEHyVY9Fc4$yh.KOE2kCcfknQ162hO53BPVxaovkh22oxgz9Ff/4tbAVrwkwi4Yj6fFnDPkE8PKGCO5oeeqdORL5k8w3N.451" ;
    isNormalUser = true;
    home = "/home/mercierm";
    shell = "/run/current-system/sw/bin/zsh";
    description = "Michael Mercier";
    extraGroups= ["wheel" "lp"];
    openssh.authorizedKeys.keys = [
    "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDXXsbhzexlZS+hCRS39cEo3BOZTLGtO8mKUE6U0gwDRNE0hE/H4Nr9Gn9NGxmmWFdTZmuaU85Z66ofe4C9Hz8pgRzB8b4Ids3XXzdeud5+znN7tKERt9Qi7a25q8vKTYlftcOIvT+6v4YVmih/NoLx5Dw9+B2tS0E20VY0skbL4s7TYmrXIrSPz6dX/JpjivF90eJSc0pVkT8ZSbZV2fygRW7JbgN490iJ+sRGnwfDjpYA7yQjyrpDJifXwdXg/NnilW6WnwbKBNXcjTIsVg1PEffZIJKAEOZzl/txNKU2kjYAZTtBGqJ491md+T3ptjvcNehia5if3GGbjm7xalzsRwOVmMisfQT4KP/cyZ66fxbU8qMgzspCjvCpEPXRQH2Q4jVWZkx2iulmB2wNbXaxs58ueelMJMO3gpZ2xBYwah7QSZK2nHG44dKfC6OAGcah7FI5+dplzwBtROWvPxkiSWJbBcxymcY5QkValWJeavC7gwDhC/zjNfa+oKRLYSsgoiiD0BRcvm+UisyGZ59C3T0lJTZpnn63RwY4WvVQzh1ltdqckZMFwaqn0ywIA9+JCD2u9P8STiRpcXq+kQnEMPYUIXRGm8KFXkdB08j8uNC0F+EF7oqgWTpGv8xVJnic48V49Vp9DDIK4BCuqgViwBMBaIqosX3j9E8JzWuAnQ== mercierm@oursbook"];
    uid = 1000;
  };

  system.stateVersion = "16.03";

  programs = {
    zsh.enable = true;
    ssh.startAgent = true;
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      inconsolata
      ubuntu_font_family
      liberation_ttf
      unifont
      fira
    ];
  };

}

