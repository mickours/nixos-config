{ config, pkgs, ... }:
{
  # Boot information

  imports = [./hardware-configuration.nix];

  # boot on /dev/sda on nixos labeled fylesystem
  boot.loader.grub.device = "/dev/sda";

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
    vim
    ctags
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
    ## Graphical environment
    #libreoffice
    #transmission_gtk
    #gitg
    #firefox
    #gnome3
    # Development environment
    gcc
    gnumake
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

  # Set root password
  users.users.root = {
    initialHashedPassword = "$6$yroFuyfM2k7eBw6u$8aJV6cf4bR0ow4HxAnkTbpGNMEoi2U0B41mRkn5lno703FABy2yP50l3Xj4fkeNxVyiEry/PV2KlxemV5.MlZ0" ;
  };

  #set password with ‘passwd’.
  users.users.mercierm = {
    initialHashedPassword = "$6$yroFuyfM2k7eBw6u$8aJV6cf4bR0ow4HxAnkTbpGNMEoi2U0B41mRkn5lno703FABy2yP50l3Xj4fkeNxVyiEry/PV2KlxemV5.MlZ0" ;
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

}

