{ config, pkgs, lib, ... }:
let
  pkgs_lists = import ../config/my_pkgs_list.nix { inherit pkgs; };
  radicaleCollection = "/data/radicale";
  radicalePort = 5232;
  webPort = 80;
  webSslPort = 443;
  smtpSslPort = 587;
  imapSslPort = 993;
  ghostPort = 8888;
  myKeys = [
    ./keys/id_rsa_oursbook.pub
    ./keys/id_rsa_vps_passless.pub
  ];
in
{
  nix.trustedUsers = [ "@wheel" ];
  # manage secrets
  # FIXME recreate the key each year with:
  # cd secrets
  # openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout privateKey.key -out vsftpd.pem
  #deployment.keys.vsftpdRsaCertFile = {
  #  text = builtins.readFile ../secrets/vsftpd.pem;
  #  user = "vsftpd";
  #  group = "ftp";
  #  permissions = "0640";
  #};

  # Needed for rsync backups
  programs.zsh.enable = true;

  # environment.extraInit = "export NIX_PATH=nixpkgs=${nixpkgs-stable}:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels";

  imports = [
    # Include the results of the hardware scan.
    ./vps-hardware-configuration.nix
    # Common config
    ../modules/common.nix
  ];

  # Use the GRUB 2 boot loader.
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  # Define on which hard drive you want to install Grub.
  boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  services.openssh.permitRootLogin = "yes";
  services.openssh.passwordAuthentication = false;
  environments.mickours.common = {
    enable = true;
    keyFiles = myKeys;
  };
  # Add root access to mmercier
  users.users.root.openssh.authorizedKeys.keyFiles = myKeys;

  system.stateVersion = "21.11";

  time.timeZone = "Europe/Paris";

  # Common config
  lib.environments.mickours.common.enable = true;

  # Add other users
  #users.extraUsers.beatrice = {
  #  description = "Béatrice Mayaux";
  #  isNormalUser = true;
  #  # extraGroups = [ "wheel" ];
  #  openssh.authorizedKeys.keyFiles =
  #    [ ./keys/id_rsa_beatrice.pub ./keys/id_rsa_oursbook.pub ];
  #};

  # Let's encrypt security settings of ACME
  security.acme.email = "admin@libr.fr";
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
      "sync.libr.fr" = {
        # Manage self signe certificate
        forceSSL = true;
        enableACME = true;

        # Add reverse proxy for radicale
        locations."/" = {
          proxyPass = "http://127.0.0.1:${toString radicalePort}/";
          extraConfig = ''
            proxy_set_header  X-Script-Name /;
            proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_pass_header Authorization;
          '';
        };
      };

      "feeds.libr.fr".forceSSL = true;
      "feeds.libr.fr".enableACME = true;

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

      #"ca.libr.fr" = {
      #  forceSSL = true;
      #  enableACME = true;
      #  # Add reverse proxy for radicale
      #  locations."/" = {
      #    proxyPass = "http://127.0.0.1:${toString ghostPort}/";
      #    extraConfig = ''
      #      proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
      #      proxy_set_header Host $Host;
      #      proxy_set_header X-Forwarded-Proto $scheme;
      #      proxy_buffering off;
      #    '';
      #  };
      #};
    };
  };

  #****************#
  #    Radicale    #
  #****************#

  services.radicale = {
    enable = true;
    settings = let
      inherit (lib) concatStrings flip mapAttrsToList;
      mailAccounts = config.mailserver.loginAccounts;
      htpasswd = pkgs.writeText "radicale.users" (concatStrings
        (flip mapAttrsToList mailAccounts
          (mail: user: mail + ":" + user.hashedPassword + "\n")));
    in {
      server = {
        hosts = "127.0.0.1:${builtins.toString radicalePort}";
      };
      auth = {
        type = "htpasswd";
        htpasswd_filename = "${htpasswd}";
        htpasswd_encryption = "bcrypt";
      };
      storage= {
        hook = "${pkgs.git}/bin/git add -A && (${pkgs.git}/bin/git diff --cached --quiet || ${pkgs.git}/bin/git commit -m 'Changes by %(user)s' )";
        filesystem_folder = "${radicaleCollection}";
      };
    };
  };

  services.cron.cronFiles = let
    # Contact and Calendar backups
    radicaleBackups = "/data/backups/radicale";

    backupScript = pkgs.writeText "backup.sh" ''
      #!${pkgs.bash}/bin/bash

      COLLECTIONS="${radicaleCollection}"
      # adapt to where you want to back up information
      BACKUP="${radicaleBackups}"

      mkdir -p "$BACKUP"
      tar zcf "$BACKUP/dump-`date +%V`.tgz" "$COLLECTIONS"
    '';
    backupCron =
      pkgs.writeText "backupRadicalCron.sh" "@weekly ${backupScript}";
  in [ backupCron ];

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
        hashedPassword =
          "$2y$05$y5JY.6WAld/Q6qP/0g6Ya.zr0BWlUaNffjoF9uhWx1TTkkrEXe8M.";
        aliases = [
          "info@libr.fr"
          "postmaster@libr.fr"
          "abuse@libr.fr"
          "admin@libr.fr"
          "michael.mercier@libr.fr"
        ];
      };
      "marine.mercier@libr.fr" = {
        hashedPassword =
          "$2y$05$391UR0l6jzkBD1MrBhKK2.utA/VQUWZbXKQhvDRSdb9BVARQ/TUAe";
        aliases = [ "marine@libr.fr" ];
      };
      "me@michaelmercier.fr" = {
        hashedPassword =
          "$2y$05$xOVdvGnsNjWxX9t.0M8kvOgLzNOqadHKgZvnM/KdnfCPx2CNtmwFu";
        catchAll = [ "michaelmercier.fr" ];
        aliases = [ "job@michaelmercier.fr" ];
      };
    };

    # Use imap on port 993 and smtp on 587
    enableImap = true;
    enableImapSsl = true;

    # Use Let's Encrypt certificates. Note that this needs to set up a stripped
    # down nginx and opens port 80.
    certificateScheme = 3;

    mailDirectory = "/data/vmail";
  };

  ##***********#
  ##   MySql   #
  ##***********#
  #services.mysql = {
  #  enable = true;
  #  package = pkgs.mysql;
  #  extraOptions = ''
  #    character-set-server    = utf8
  #    collation-server        = utf8_unicode_ci
  #  '';
  #};

  #*****************#
  #  Tiny Tiny RSS  #
  #*****************#
  services.tt-rss.enable = true;
  services.tt-rss.selfUrlPath = "https://feeds.libr.fr/";
  services.tt-rss.virtualHost = "feeds.libr.fr";

  #services.vsftpd = {
  #  enable = true;
  #  #forceLocalLoginsSSL = true;
  #  #forceLocalDataSSL = true;
  #  #userlistDeny = false;
  #  #localUsers = true;
  #  anonymousUser = true;
  #  #userlist = ["beatrice"];
  #  #rsaCertFile = "/run/keys/vsftpdRsaCertFile";
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
    ] ++ pkgs_lists.common;
}
