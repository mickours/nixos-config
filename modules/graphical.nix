{ config, lib, pkgs, ... }:
let
  pkgs_lists = import ../config/my_pkgs_list.nix { inherit pkgs; };
  cfg = config.environment.mickours.graphical;
in
  with lib;
  {
    imports = [
      "${builtins.fetchTarball https://github.com/rycee/home-manager/archive/master.tar.gz}/nixos"
    ];
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
        # Disable tracker to avoid it to suck my vitality
        gnome3.tracker.enable = mkForce false;
        gnome3.tracker-miners.enable = mkForce false;

        syncthing = {
          enable = true;
          user = "mmercier";
          group = "mmercier";
          dataDir = /home/mmercier/.config/syncthing;
          systemService = false;
        };
      };

      # Auto unlock keyring with GDM (does not work!!!)
      # TODO create an issue...
      #security.pam.services.gdm.enableGnomeKeyring = true;

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

      # for system monitor gnome extension (maybe it not necessary anymore)
      services.xserver.desktopManager.gnome3.sessionPath = [
        pkgs.json_glib
        pkgs.glib_networking
        pkgs.libgtop
      ];
      # Add Workaround for USB 3 Scanner for SANE
      # See http://sane-project.org/ Note 3
      environment.variables.SANE_USB_WORKAROUND = "1";

      # WARNING extensions need to be installed in the browser AND links have
      # to be created in .mozilla, see for full workaround:
      # https://github.com/NixOS/nixpkgs/issues/47340)
      programs.browserpass.enable = true;
      nixpkgs.config.firefox.enableGnomeExtensions = true;
      #services.gnome3.chrome-gnome-shell.enable = true;

      #nixpkgs.config.packageOverrides = pkgs: rec
      #{
      #  gnome3 = pkgs.gnome3.overrideDerivation (gnomepkgs: rec {
      #    gnome-keyring = pkgs.gnome3.gnome-keyring.overrideAttrs (attrs: {
      #      configureFlags = attrs.configureFlags ++ ["--disable-ssh-agent"];
      #    });
      #  });
      #};



      home-manager.users.mmercier = {
        # Make ssh-agent works: see https://github.com/NixOS/nixpkgs/issues/42291
        # Prevent clobbering SSH_AUTH_SOCK
        home.sessionVariables.GSM_SKIP_SSH_AGENT_WORKAROUND = "1";

        # Disable gnome-keyring ssh-agent
        xdg.configFile."autostart/gnome-keyring-ssh.desktop".text = ''
          ${lib.fileContents "${pkgs.gnome3.gnome-keyring}/etc/xdg/autostart/gnome-keyring-ssh.desktop"}
          Hidden=true
        '';
      };
    };
  }
