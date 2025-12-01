{ config, lib, pkgs, inputs, ... }:
let
  pkgs_lists = import ../config/my_pkgs_list.nix { inherit pkgs; dotfiles = inputs.my_dotfiles; adrienPkgs = inputs.adrien_config.packages; };
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

    services.pulseaudio.enable = false;
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
      };
      # Enable the Gnome Desktop Environment.
      desktopManager.gnome.enable = true;
      displayManager.gdm.enable = true;

      gnome.gnome-online-accounts.enable = true;
      gnome.gnome-browser-connector.enable = true;
    };

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
    ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

    # every machine should be running antivirus
    services.clamav.updater.enable = true;

    # enable cron table
    services.cron.enable = true;

    programs.browserpass.enable = true;
    # Needed for browserpass to call gnupg
    programs.gnupg.agent.enable = true;
    # Enable native support of AppImage format
    programs.appimage.binfmt = true;
  };
}
