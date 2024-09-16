{ config, pkgs, lib, inputs, ... }:
let
  pkgs_lists = import ../config/my_pkgs_list.nix { inherit pkgs; };
  webPort = 80;
  webSslPort = 443;
  myKeys = [
    ./keys/id_rsa_oursbook.pub
    ./keys/id_rsa_vps_passless.pub
  ];
in
{
  system.stateVersion = "24.05";
  nix.settings.trusted-users = [ "@wheel" ];

  # Needed for rsync backups
  programs.zsh.enable = true;

  imports = [
    # Include the results of the hardware scan.
    ./vps-hardware-configuration.nix
    # Common config
    ../modules/common.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";
  services.openssh.settings.PasswordAuthentication = false;
  environments.mickours.common = {
    enable = true;
    keyFiles = myKeys;
  };
  # Add root access to mmercier
  users.users.root.openssh.authorizedKeys.keyFiles = myKeys;

  # Add other users
  users.extraUsers.beatrice = {
    description = "Béatrice Mayaux";
    isNormalUser = true;
    openssh.authorizedKeys.keyFiles = [ ./keys/id_rsa_beatrice.pub ];
    uid = 1003;
  };

  time.timeZone = "Europe/Paris";

  # Avoid using to much space with the logs
  services.journald.extraConfig = "SystemMaxUse=100M";

  # Common config
  lib.environments.mickours.common.enable = true;

  # Let's encrypt security settings of ACME
  security.acme.defaults.email = "admin@libr.fr";
  security.acme.acceptTerms = true;

  #*************#
  #    Nginx    #
  #*************#

  services.nginx = {
    enable = true;
    appendHttpConfig = ''
      server_names_hash_bucket_size 64;
    '';
    virtualHosts = {
      "nextcloud.libr.fr".forceSSL = true;
      "nextcloud.libr.fr".enableACME = true;

      "michaelmercier.fr" = {
        locations."/" = { root = "/data/public/mmercier/website"; };
        # Static file serving
        locations."/files/" = {
          root = "/data/public/mmercier";
          extraConfig = ''
            autoindex on;
          '';
        };
      };
      "jeme.libr.fr" = {
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/data/public/beatrice/website";
        }; # Static file serving
        locations."/files/" = {
          root = "/data/public/beatrice";
          extraConfig = ''
            autoindex on;
          '';
        };
      };
    };
  };

  #****************#
  #   MailServer   #
  #****************#

  mailserver = {
    enable = true;
    fqdn = "mail.libr.fr";
    domains = [ "libr.fr" "michaelmercier.fr" ];

    # Use `mkpasswd -m sha-512` to create the salted password
    loginAccounts = {
      "mickours@libr.fr" = {
        hashedPasswordFile = "/data/keys/mickours-at-libr-dot-fr";
        # "$2y$05$y5JY.6WAld/Q6qP/0g6Ya.zr0BWlUaNffjoF9uhWx1TTkkrEXe8M.";
        aliases = [
          "info@libr.fr"
          "postmaster@libr.fr"
          "abuse@libr.fr"
          "admin@libr.fr"
          "michael.mercier@libr.fr"
        ];
      };
      "marine.mercier@libr.fr" = {
        hashedPasswordFile = "/data/keys/marine-mercier-at-libr-dot-fr";
        aliases = [ "marine@libr.fr" ];
      };
      "me@michaelmercier.fr" = {
        hashedPasswordFile = "/data/keys/me-at-michaelmercier-dot-fr";
        catchAll = [ "michaelmercier.fr" ];
        aliases = [ "job@michaelmercier.fr" ];
      };
      "labelleverte@libr.fr" = {
        hashedPasswordFile = "/data/keys/labelleverte-at-libr-dot-fr";
        aliases = [ "lbv@libr.fr" ];
      };
    };

    # Use imap on port 993 and smtp on 587
    enableImap = true;
    enableImapSsl = true;
    enableManageSieve = true;
    hierarchySeparator = "/";

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = "acme-nginx";

    mailDirectory = "/data/vmail";
    dkimKeyDirectory = "/data/dkim";
    sieveDirectory = "/data/sieve";
  };

  ##***************#
  ##   NextCloud   #
  ##***************#

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud29;
    home = "/data/nextcloud";
    hostName = "nextcloud.libr.fr";
    https = true;
    config.adminpassFile = "/data/admin_nextcloud";
    config.defaultPhoneRegion = "FR";
    # Forces Nextcloud to use HTTPS
    config.overwriteProtocol = "https";
    config.objectstore.s3 = {
      enable = true;
      region = "eu-west-3";
      key = "AKIAZFTZEYESUAQVO5MO";
      bucket = "nextcloud-libr-fr";
      secretFile = "/data/s3_nextcloud";
      autocreate = true;
    };
    # For face recognition App
    phpExtraExtensions = all: [ all.pdlib all.bz2 all.apcu ];
    maxUploadSize = "1G";
    fastcgiTimeout = 600;
    # Computed with https://spot13.com/pmcalculator/
    poolSettings = {
      "pm" = "dynamic";
      "pm.max_children" = "44";
      "pm.start_servers" = "11";
      "pm.min_spare_servers" = "11";
      "pm.max_spare_servers" = "33";
      "pm.max_requests" = "500";
    };
  };

  ## For backgroud job for face recognition
  #systemd.timers."nextcloud-face-recognition" = {
  #  wantedBy = [ "timers.target" ];
  #  timerConfig = {
  #    OnCalendar = "daily";
  #    Persistent = true;
  #    Unit = "nextcloud-face-recognition.service";
  #  };
  #};
  #systemd.services."nextcloud-face-recognition" = {
  #  script = ''
  #    set -eu
  #    ${pkgs.nextcloud28}/bin/nextcloud-occ face:background_job -t 3600
  #  '';
  #  serviceConfig = {
  #    Type = "oneshot";
  #    User = "nextcloud";
  #  };
  #};

  #*************#
  #   Network   #
  #*************#
  networking = { firewall.allowedTCPPorts = [ webPort webSslPort ]; };

  #*************#
  # Admin tools #
  #*************#
  environment.systemPackages = with pkgs;
    [
      dstat
      wget
      git # Needed for radicale backup
      rsync # for backups
      goaccess # For web site traffic analytics
      ripgrep
      neovim
      # For nextcloud apps: Memories
      exiftool
      ffmpeg
    ] ++ pkgs_lists.common;
}
