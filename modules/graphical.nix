{ config, lib, pkgs, inputs, ... }:
let
  pkgs_lists = import ../config/my_pkgs_list.nix { inherit pkgs; dotfiles = inputs.my_dotfiles; };
  hp-driver = pkgs.callPackage ../pkgs/hp-driver/hp-driver-MFP-178-nw.nix { };
  cfg = config.environments.mickours.graphical;
in
with lib; {
  options.environments.mickours.graphical = {
    enable = mkEnableOption "graphical";
    myuser = mkOption { type = types.str; };
  };

  config = mkIf config.environments.mickours.graphical.enable {
    environment.systemPackages = pkgs_lists.graphical;

    # Enable bluetooth
    #hardware.pulseaudio = {
    #  enable = false;

    #  # NixOS allows either a lightweight build (default) or full build of PulseAudio to be installed.
    #  # Only the full build has Bluetooth support, so it must be selected here.
    #  package = pkgs.pulseaudioFull;
    #  # For echo-cancelation virtual interface add the following line to the conf
    #  extraConfig = ''
    #    load-module module-echo-cancel
    #    load-module module-switch-on-connect
    #  '';
    #};
    hardware.pulseaudio.enable = false;
    hardware.bluetooth.enable = true;
    # rtkit is optional but recommended
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # If you want to use JACK applications, uncomment this
      #jack.enable = true;
      systemWide = true;
    };
    environment.etc = {
      "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
        bluez_monitor.properties = {
            ["bluez5.enable-sbc-xq"] = true,
            ["bluez5.enable-msbc"] = true,
            ["bluez5.enable-hw-volume"] = true,
            ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '';
    };

    services = {
      # Install but disable open SSH
      openssh = {
        enable = false;
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
      avahi.nssmdns4 = true;

      # Enable the windowing system.
      xserver = {
        enable = true;
        xkb.layout = "fr";
        xkb.options = "eurosign:e";
        enableCtrlAltBackspace = true;

        # Enable the Gnome Desktop Environment.
        desktopManager.gnome.enable = true;
        displayManager.gdm.enable = true;
      };

      gnome.gnome-online-accounts.enable = true;
      gnome.gnome-browser-connector.enable = true;
      # Disable file tracker to avoid it to suck my vitality
      gnome.tinysparql.enable = mkForce false;
      gnome.localsearch.enable = mkForce false;

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
      extraGroups = [ "audio" "wheel" "lp" "networkmanager" "pipewire" ];
    };

    # Make fonts better...
    fonts.fontconfig = { enable = true; };
    # Add micro$oft fonts
    fonts.packages = with pkgs; [
      corefonts
      # helvetica-neue-lt-std
      twemoji-color-font
      nerdfonts
    ];

    # every machine should be running antivirus
    services.clamav.updater.enable = true;

    # enable cron table
    services.cron.enable = true;

    # Add Workaround for USB 3 Scanner for SANE
    # See http://sane-project.org/ Note 3
    environment.variables.SANE_USB_WORKAROUND = "1";

    programs.browserpass.enable = true;
    #programs.firefox.nativeMessagingHosts.browserpass = true;
    # Needed for browserpass to call gnupg
    programs.gnupg.agent.enable = true;
    # Enable native support of AppImage format
    programs.appimage.binfmt = true;
  };
}
