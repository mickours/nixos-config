{
  config,
  pkgs,
  lib,
  inputs,
  adrienPkgs,
  dotfiles,
  ...
}:
let
  pkgs_lists = import ../config/my_pkgs_list.nix { inherit pkgs adrienPkgs dotfiles; };
  webPort = 80;
  webSslPort = 443;
  myKeys = [
    ./keys/id_rsa_oursbook.pub
    ./keys/id_rsa_vps_passless.pub
  ];
  exiftool_13_44 = pkgs.exiftool.overrideAttrs (oldAttrs: rec {
    src = pkgs.fetchFromGitHub {
      owner = "exiftool";
      repo = "exiftool";
      tag = version;
      hash = "sha256-o9/qg+BQSc2MiZIqvyFKPtCBHU64QLMhA2AcvDCph04=";
    };
    version = "13.44";
  });
in
{
  system.stateVersion = "25.11";
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
  users.users.root.shell = pkgs.zsh;

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
        locations."/" = {
          root = "/data/public/mmercier/website";
        };
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
    domains = [
      "libr.fr"
      "michaelmercier.fr"
    ];

    # Use `mkpasswd -m sha-512` to create the salted password
    loginAccounts = {
      "mickours@libr.fr" = {
        hashedPasswordFile = "/data/keys/mickours-at-libr-dot-fr";
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
      "nextcloud@libr.fr" = {
        hashedPasswordFile = "/data/keys/nextcloud-at-libr-dot-fr";
        aliases = [ "ne-pas-repondre@libr.fr" ];
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

    # Enable DKIM reporting
    dmarcReporting.enable = true;

    # manage data migration
    stateVersion = 3;

    # Enable monit monitoring and alerting
    monitoring.enable = true;
    monitoring.alertAddress = "admin@libr.fr";

    # Enable local rsnapshot backup
    backup.enable = true;
    backup.snapshotRoot = "/data/mail-backups";

    # put everything in the /data folder to simplify backups
    mailDirectory = "/data/vmail";
    dkimKeyDirectory = "/data/dkim";
    sieveDirectory = "/data/sieve";
  };

  ##***************#
  ##   NextCloud   #
  ##***************#

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud32;
    home = "/data/nextcloud";
    hostName = "nextcloud.libr.fr";
    https = true;
    config.adminpassFile = "/data/admin_nextcloud";
    # DB config
    # config.dbtype = "sqlite";
    config.dbtype = "pgsql";
    config.dbhost = "/run/postgresql";

    # Forces Nextcloud to use HTTPS
    settings = {
      overwriteProtocol = "https";
      default_phone_region = "FR";

      log_type = "file";

      mail_domain = "libr.fr";
      mail_from_address = "ne-pas-repondre";
      mail_smtpmode = "smtp";
      mail_smtphost = "mail.libr.fr";
      mail_smtpport = 465;
      mail_smtpsecure = "ssl";
      mail_smtpauth = true;
      mail_smtpname = "nextcloud@libr.fr";
      mail_smtptimeout = 30;
      mail_smtpdebug = true;
      # WARNING smtp password is injected manually

      apps.memories.exiftool_no_local = true;
    };

    config.objectstore.s3 = {
      enable = true;
      region = "eu-west-3";
      key = "AKIAZFTZEYESUAQVO5MO";
      bucket = "nextcloud-libr-fr";
      secretFile = "/data/s3_nextcloud";
      # verify_bucket_exists = true;
      # region = "fr-par";
      # hostname = "s3.fr-par.scw.cloud";
      # key = "SCWM8NR3996ET9FMHQCC";
      # bucket = "primary0-nextcloud-libr-fr";
      # secretFile = "/data/s3_nextcloud_scw";
    };
    # For face recognition App
    phpExtraExtensions = all: [
      all.pdlib
      all.bz2
      all.apcu
    ];
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
    phpOptions = {
      "opcache.interned_strings_buffer" = "16";
    };
  };

  services.postgresql = {
    # Copied & adapted from nixpkgs
    enable = true;
    identMap = ''
      nextcloud nextcloud nextcloud
      nextcloud root nextcloud
    '';
    authentication = ''
      local all nextcloud peer map=nextcloud
    '';
    ensureDatabases = [ "nextcloud" ];
    ensureUsers = [
      {
        name = "nextcloud";
        ensureDBOwnership = true;
      }
    ];
    dataDir = "/data/psql/${config.services.postgresql.package.psqlSchema}";
  };
  services.postgresqlBackup = {
    enable = true;
    backupAll = true;
    location = "/data/psql-backups";
  };

  # Fix nextcloud memories indexing
  systemd.services.nextcloud-cron = {
    path = [
      (pkgs.perl.withPackages (ps: [ exiftool_13_44 ]))
    ];
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
  networking = {
    firewall.allowedTCPPorts = [
      webPort
      webSslPort
    ];
  };

  #*************#
  # Admin tools #
  #*************#
  environment.systemPackages =

    with pkgs;
    [
      wget
      # for backups
      rsync
      borgbackup
      # For web site traffic analytics
      goaccess
      # Extra tools
      ripgrep
      neovim
      jq
      restic
      sqlite-interactive
      dig
      unixtools.netstat
      git
      # For nextcloud apps: Memories
      exiftool_13_44
      ffmpeg
    ]
    ++ pkgs_lists.common;
}
