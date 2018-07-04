let
  nixpkgs-stable = (fetchTarball "https://github.com/NixOS/nixpkgs/archive/18.03.tar.gz");
  radicaleCollection = "/data/radicale";
  radicalePort = 5232;
  webPort = 80;
  webSslPort = 443;
  smtpSslPort = 587;
  imapSslPort = 993;
  ghostPort = 8888;

in
{
  network.description = "Michael Mercier Personal Network";

  vps =
  { config, pkgs, nodes, lib, ... }:

  {
    deployment.targetHost = "176.10.125.101";

    environment.extraInit = "export NIX_PATH=nixpkgs=${nixpkgs-stable}:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels";

    imports =
    [
      # Include the results of the hardware scan.
      ./vps-hardware-configuration.nix
      # Include my config
      ./my-config.nix
      # Mail server
      (builtins.fetchTarball "https://github.com/r-raymond/nixos-mailserver/archive/v2.1.4.tar.gz")
      # Blog with Ghost
       ./blog/service.nix
    ];

    # Use the GRUB 2 boot loader.
    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    # Define on which hard drive you want to install Grub.
    boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
    services.openssh.permitRootLogin = "yes";

    system.stateVersion = "18.03";

    time.timeZone = "Europe/Paris";

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
            proxyPass = "http://localhost:${toString radicalePort}/";
            extraConfig = ''
              proxy_set_header  X-Script-Name /;
              proxy_set_header  X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_pass_header Authorization;
            '';
          };
        };
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

        "ca.libr.fr" = {
          forceSSL = true;
          enableACME = true;
          # Add reverse proxy for radicale
          locations."/" = {
            proxyPass = "http://localhost:${toString ghostPort}/";
            extraConfig = ''
              proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
              proxy_set_header Host $http_host;
              proxy_set_header X-Forwarded-Proto $scheme;
              proxy_buffering off;
            '';
          };
        };
      };
    };

    #****************#
    #    Radicale    #
    #****************#

    services.radicale = {
      enable=true;
      config = let
          inherit (lib) concatStrings flip mapAttrsToList;
          mailAccounts = config.mailserver.loginAccounts;
          htpasswd = pkgs.writeText "radicale.users" (concatStrings
            (flip mapAttrsToList mailAccounts (mail: user:
              mail + ":" + user.hashedPassword + "\n"
            ))
          );
        in ''
          [server]
          hosts = localhost:${builtins.toString radicalePort}

          [auth]
          type = htpasswd
          htpasswd_filename = ${htpasswd}
          htpasswd_encryption = crypt

          [storage]
          hook = ${pkgs.git}/bin/git add -A && (${pkgs.git}/bin/git diff --cached --quiet || ${pkgs.git}/bin/git commit -m "Changes by %(user)s" )
          filesystem_folder = ${radicaleCollection}
      '';
    };

    services.cron.cronFiles =
    let
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
      backupCron = pkgs.writeText "backupRadicalCron.sh" "@weekly ${backupScript}";
    in
    [ backupCron ];


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
            hashedPassword = "$6$JyR6AQ1j5RbDVw$bwcOX32dt16XRGtFuU6K.JHa1ekWac4Y/AlMZexH7CWA24sP32u1mPdpdjBpdsHApblG4Zn5wzMKmyh8Ipzw5.";
            aliases = [
              "info@libr.fr"
              "postmaster@libr.fr"
              "abuse@libr.fr"
              "michael.mercier@libr.fr"
            ];
          };
          "ca@libr.fr" = {
            hashedPassword = "$6$shmgOepxJsk$zTuq0fL9v26wuY1nqin54tIO7CvMxJUpoKSvsWtLjQIOJpUo/i5muq6OdtrW2/s49Wzv399Rpm45bQtrvrilI/";
            aliases = [
              "beatrice.mayaux@libr.fr"
            ];
          };
          "marine.mercier@libr.fr" = {
            hashedPassword = "$6$G.SkAtt3$FPdKoimZOY3e3JC0ByI0bb452W7z5q.rA95xUeeM0i6UekM7DDZfh89YfQReOIFDo3auUCn2FS/5oZ.RdWtbo1";
            aliases = [
              "marine@libr.fr"
            ];
          };
          "me@michaelmercier.fr" = {
            hashedPassword = "$6$JyR6AQ1j5RbDVw$bwcOX32dt16XRGtFuU6K.JHa1ekWac4Y/AlMZexH7CWA24sP32u1mPdpdjBpdsHApblG4Zn5wzMKmyh8Ipzw5.";
            catchAll = [ "michaelmercier.fr" ];
            aliases = [
              "job@michaelmercier.fr"
            ];
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

    #*************#
    #   Network   #
    #*************#
    networking = {
      firewall.allowedTCPPorts = [ radicalePort webPort webSslPort ];
    };

    #*************#
    # Admin tools #
    #*************#
    environment.systemPackages = with pkgs; [
      dstat
      wget
      git # Needed for radicale backup
      rsync # for backups
    ];
  };


}
