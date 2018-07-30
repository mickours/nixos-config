{ config, lib, pkgs, ... }:
let
  pkgs_lists = import ../config/my_pkgs_list.nix { inherit pkgs; };
  cfg = config.environment.mickours.graphical;
in
  with lib;
  {
    options.environments.mickours.graphical = {
      enable = mkEnableOption "graphical";
      keys = mkOption {
        type = types.listOf types.string;
        default = [];
        example = [];
        description = ''
          The list of Ssh keys allowed to log.
        '';
      };
    };

    config = mkIf config.environments.mickours.graphical.enable {
      environment.systemPackages = pkgs_lists.graphical;

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
          enableCtrlAltBackspace = true;

          # Enable the Gnome Desktop Environment.
          desktopManager.gnome3.enable = true;
          displayManager.gdm.enable = true;
        };

        gnome3.gnome-online-accounts.enable = true;
        gnome3.chrome-gnome-shell.enable = true;

        syncthing = {
          enable = true;
          user = "mmercier";
          group = "mmercier";
          dataDir = /home/mmercier/.config/syncthing;
          systemService = false;
        };
      };

      # Auto unlock keyring with GDM
      security.pam.services.gdm.enableGnomeKeyring = true;

      # Make fonts better...
      fonts.fontconfig = {
        enable = true;
        ultimate.enable = true;
      };
      # Add micro$oft fonts
      fonts.fonts = [ pkgs.corefonts ];

      # every machine should be running antivirus
      services.clamav.updater.enable = true;

      # enable cron table
      services.cron.enable = true;

      services.xserver.desktopManager.gnome3.sessionPath = [
        pkgs.json_glib
        pkgs.glib_networking
        pkgs.libgtop
      ];
      # Add Workaround for USB 3 Scanner for SANE
      # See http://sane-project.org/ Note 3
      environment.variables.SANE_USB_WORKAROUND = "1";
    };
  }
