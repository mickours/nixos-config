# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config,
  pkgs ? import ../nixpkgs { },
  ...
}:
rec {

  nix = {
    # make sure dependencies are well defined
    useSandbox = true;

    # build with 3 out of 4 cores
    #buildCores = 3;

    # keep build dpendencies to enable offline rebuild
    extraOptions = ''
      gc-keep-outputs = true
      gc-keep-derivations = true
      '';
  };

  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      ./config/fix-keymap.nix
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


  ## manage encrypted HOME partition
  #systemd.generator-packages = [
  #  pkgs.systemd-cryptsetup-generator
  #];

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
  };


  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = with pkgs; [
    ## Nix related
    nox
    nix-repl

    ## install nix-home
    #((pkgs.callPackage ./pkgs/nix-home.nix) {})

    ## Utils
    ntfs3g
    psmisc
    file

    ## Console environment
    vim
    # vim plugins
    vimPlugins.YouCompleteMe

    neovim

    tmux

    ranger
    # ranger previews
    libcaca   # video
    highlight # code
    atool     # archives
    w3m       # web
    poppler   # PDF
    mediainfo # audio and video

    pmutils
    git
    nmap
    unzip
    python3
    python2
    htop
    tree
    gnupg
    pass
    zsh
    nix-zsh-completions
    ncdu
    iotop
    emacs

    ## Graphical environment
    # For system Monitor plugin
    gobjectIntrospection
    libgtop

    # Fix Gnome crash
    gnome3.gjs

    usbutils

    firefox
    chrome-gnome-shell
    flashplayer

    gnome3.evolution
    aspellDicts.fr
    aspellDicts.en
    gnome3.gnome-disk-utility

    ## Development environment
    gcc
    ctags
    gnumake
    wget
    cmake
    gitg

    ## Pro
    cntlm
    opensc
    polipo
    libreoffice

    ## Backups and sync
    syncthing
    transmission_gtk

  ];

  environment.gnome3.excludePackages = [
    # gnome-software doesn't build and it wouldn't work with nixos anyway, at
    # least before something like this is done:
    # RFC: Generating AppStream Metadata #15932:
    # https://github.com/NixOS/nixpkgs/issues/15932
    pkgs.gnome3.gnome-software
  ];

  # use Vim by default
  environment.sessionVariables.EDITOR="nvim";

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

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
      drivers = [ pkgs.samsung-unified-linux-driver ];
    };
    # Needed for printer discovery
    avahi.enable = true;

    # Enable the X11 windowing system.
    xserver = {
      enable = true;
      layout = "fr";
      xkbOptions = "eurosign:e";
      libinput.enable = true;

      # Enable the Gnome Desktop Environment.
      desktopManager.gnome3.enable = true;
      #desktopManager.plasma5.enable = true;

      # Include fix for gdm locales: https://github.com/NixOS/nixpkgs/issues/14318#issuecomment-309250231
      displayManager.gdm.enable = true;
      localectlFix.enable = true;
    };

    gnome3.gnome-keyring.enable = true;
    gnome3.at-spi2-core.enable = true;
  };

  # Fix GDM warining issue: https://github.com/NixOS/nixpkgs/issues/24172#issuecomment-304540789
  # systemd.targets."multi-user".conflicts = [ "getty@tty1.service" ];

  # Enable keyring unlock with session password
  #security.pam.services = with pkgs;[
  #  { name = "login";
  #    text = ''
  #      auth     optional    ${gnome3.gnome_keyring}/lib/security/pam_gnome_keyring.so
  #      session  optional    ${gnome3.gnome_keyring}/lib/security/pam_gnome_keyring.so auto_start
  #    '';
  #  }
  #  { name = "passwd";
  #    text = ''
  #      password	optional	${gnome3.gnome_keyring}/lib/security/pam_gnome_keyring.so
  #    '';
  #  }
  #];

  # Make fonts better...
  fonts.fontconfig = {
    enable = true;
    ultimate.enable = true;
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

  # TODO override polipo conf with parent proxy "http://193.56.47.8:8080";

  programs = {
    # FIXME (not sure if it is necessary...
    # Enable system wide zsh and ssh agent
    zsh.enable = true;
    ssh.startAgent = true;

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
  programs.browserpass.enable = true;
  programs.gnupg.agent.enableBrowserSocket = true;
  programs.gnupg.agent.enable = true;

  # enable thefuck!
  programs.thefuck.enable = false;

  # enable cron table
  services.cron.enable = true;

  security.sudo.extraConfig = ''
    Defaults   insults
    '';

  # fix aspell path
  # https://github.com/NixOS/nixpkgs/issues/28815
  #system.replaceRuntimeDependencies = with pkgs; [
  #    { original = aspell;
  #      replacement = aspell.overrideAttrs (oldAttrs: rec {
  #         patchPhase = oldAttrs.patchPhase + ''
  #         patch -p1 < ${./patches/dict-dir-from-nix-profiles.patch}
  #       '';
  #      });
  #   }
  #];

  nixpkgs.config.packageOverrides = pkgs:
  {
    flashplayer = pkgs.flashplayer.overrideAttrs (oldAttr: rec {
      version = "27.0.0.170";
      src = pkgs.fetchurl {
        url =
        "https://fpdownload.adobe.com/get/flashplayer/pdc/${version}/flash_player_npapi_linux.x86_64.tar.gz";
        sha256 = "0hyc25ygxrp8k0w1xmg5wx1d2l959glc23bjswf30agwlpyn2rwn";
      };
    });
    sudo = pkgs.sudo.override { withInsults = true; };
  };
}

