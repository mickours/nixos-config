{ config, pkgs, ... }:

{
  networking.hostName = "kakahuette";

  imports =
    [
      ./kakahuette-hardware-configuration.nix
      ../modules/common.nix
      ../modules/graphical.nix
    ];

  environments.mickours.common.enable = true;
  environments.mickours.graphical.enable = true;
  environments.mickours.graphical.myuser = "marine";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  #i18n.consoleKeyMap = "fr";
  i18n.defaultLocale = "fr_FR.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Paris";

  nixpkgs.config.allowUnfree = true;

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

  environment.systemPackages = with pkgs; [
    # Web
    firefox
    # Media
    transmission_gtk
    ## Enable numock by default
    numlockx
    ## Games
    gnome3.aisleriot
  ];

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

  nixpkgs.config.firefox.enableAdobeFlash = true;

  users.extraUsers.marine = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "lp" "networkmanager" ];
  };
}
