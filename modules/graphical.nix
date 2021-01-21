{ config, lib, pkgs, ... }:
let
  pkgs_lists = import ../config/my_pkgs_list.nix { inherit pkgs; };
  hp-driver = pkgs.callPackage ../pkgs/hp-driver/hp-driver-MFP-178-nw.nix { };
  cfg = config.environments.mickours.graphical;
in with lib; {
  options.environments.mickours.graphical = {
    enable = mkEnableOption "graphical";
    myuser = mkOption { type = types.str; };
  };

  config = mkIf config.environments.mickours.graphical.enable {
    environment.systemPackages = pkgs_lists.graphical;

    # Enable bluetooth
    hardware.pulseaudio = {
      enable = true;

      # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
      # Only the full build has Bluetooth support, so it must be selected here.
      package = pkgs.pulseaudioFull;
      extraModules = [ pkgs.pulseaudio-modules-bt ];
      # For echo-cancelation virtual interface add the following line to the conf
      # load-module module-echo-cancel
      extraConfig = ''
        load-module module-switch-on-connect
      '';
    };
    hardware.bluetooth.enable = true;
    # Bluetooth command for headsets
    systemd.user.services.mpris-proxy = {
      Unit.Description = "Mpris proxy";
      Unit.After = [ "network.target" "sound.target" ];
      Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
      Install.WantedBy = [ "default.target" ];
    };

    services = {
      # Install but disable open SSH
      openssh = {
        enable = false;
        permitRootLogin = "false";
      };

      # Enable CUPS to print documents.
      printing = {
        enable = true;
        browsing = true;
        drivers =
          [ pkgs.samsung-unified-linux-driver pkgs.hplipWithPlugin hp-driver ];
      };
      # Needed for printer discovery
      avahi.enable = true;
      avahi.nssmdns = true;

      # Enable the windowing system.
      xserver = {
        enable = true;
        layout = "fr";
        xkbOptions = "eurosign:e";
        enableCtrlAltBackspace = true;

        # Enable the Gnome Desktop Environment.
        desktopManager.gnome3.enable = true;
        displayManager.gdm.enable = true;
      };

      gnome3.gnome-online-accounts.enable = true;
      # Disable tracker to avoid it to suck my vitality
      gnome3.tracker.enable = mkForce false;
      gnome3.tracker-miners.enable = mkForce false;

      syncthing = {
        enable = true;
        user = cfg.myuser;
        group = cfg.myuser;
        dataDir = /home + cfg.myuser + /.config/syncthing;
        systemService = false;
      };
    };

    # Auto unlock keyring with GDM (does not work!!!)
    # TODO create an issue...
    #security.pam.services.gdm.enableGnomeKeyring = true;

    # Add gdm to my user's groups
    users.extraUsers."${cfg.myuser}" = {
      extraGroups = [ "audio" "wheel" "lp" "networkmanager" ];
    };

    # Make fonts better...
    fonts.fontconfig = { enable = true; };
    # Add micro$oft fonts
    fonts.fonts = with pkgs; [
      corefonts
      helvetica-neue-lt-std
      twemoji-color-font
    ];

    # every machine should be running antivirus
    services.clamav.updater.enable = true;

    # enable cron table
    services.cron.enable = true;

    # Add Workaround for USB 3 Scanner for SANE
    # See http://sane-project.org/ Note 3
    environment.variables.SANE_USB_WORKAROUND = "1";

    programs.browserpass.enable = true;
    nixpkgs.config.firefox.enableBrowserpass = true;
    nixpkgs.config.firefox.enableGnomeExtensions = true;

  };
}
