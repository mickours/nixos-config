let
  nixpkgs-stable = (fetchTarball "https://github.com/NixOS/nixpkgs/archive/18.03.tar.gz");
  radicaleCollection = "/data/radicale";
  radicalePort = 5232;
  webPort = 80;
  webSslPort = 443;
  smtpSslPort = 587;
  imapSslPort = 993;
in
{
  network.description = "Michael Mercier Personal Network";

  vps =
  { config, pkgs, nodes, ... }:

  {
    deployment.targetHost = "176.10.125.101";

    environment.extraInit = "export NIX_PATH=nixpkgs=${nixpkgs-stable}:nixos-config=/etc/nixos/configuration.nix:/nix/var/nix/profiles/per-user/root/channels";

    imports =
    [
      # Include the results of the hardware scan.
      ./vps-hardware-configuration.nix
      # Include my config
      ./my-config.nix
    ];

    # Use the GRUB 2 boot loader.
    boot.loader.grub.enable = true;
    boot.loader.grub.version = 2;
    # Define on which hard drive you want to install Grub.
    boot.loader.grub.device = "/dev/vda"; # or "nodev" for efi only

    # Enable the OpenSSH daemon.
    services.openssh.enable = true;
    services.openssh.permitRootLogin = "yes";


    #containers.radicale.bindMounts = { "/data" = {hostPath = "/data";}; };

    #containers.mailserver.bindMounts = { "/data" = {hostPath = "/data";}; };

    networking = {
      firewall.allowedTCPPorts = [ radicalePort webPort webSslPort ];

      nat = {
        enable=true;
        internalInterfaces=["ve-+"];
        externalInterface = "enp0s3";
        forwardPorts = [
          {
            destination = "${nodes.nginx.config.networking.privateIPv4}:${builtins.toString webPort}";
            sourcePort =  webPort;
          }
          {
            destination = "${nodes.nginx.config.networking.privateIPv4}:${toString webSslPort}";
            sourcePort =  webSslPort;
          }
          {
            destination = "${nodes.mailserver.config.networking.privateIPv4}:${toString imapSslPort}";
            sourcePort =  imapSslPort;
          }
          {
            destination = "${nodes.mailserver.config.networking.privateIPv4}:${toString smtpSslPort}";
            sourcePort =  smtpSslPort;
          }
          {
            destination = "${nodes.radicale.config.networking.privateIPv4}:${toString radicalePort}";
            sourcePort =  radicalePort;
          }
        ];
      };
    };

    # Admin tools
    environment.systemPackages = with pkgs; [
      dstat
      wget
      git # Needed for radicale backup
      rsync # for backups
    ];

    system.stateVersion = "18.03";
  };



  nginx =
  { resources, nodes, ... }:
  {
    deployment = {
      targetEnv = "container";
      container.host = resources.machines.vps;
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts = {
      "sync.michaelmercier.fr" = {
        # Manage self signe certificate
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www";
        };

        # Add reverse proxy for radicale
        locations."/radicale/" = {
          proxyPass = "http://${nodes.radicale.config.networking.privateIPv4}:${builtins.toString radicalePort}/";
          extraConfig = ''
            proxy_set_header     X-Script-Name /radicale;
            proxy_set_header     X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header     X-Remote-User $remote_user;
          '';
        };
      };
      "mail.libr.fr" = {
        locations."/" = {
          proxyPass = "http://${nodes.mailserver.config.networking.privateIPv4}/";
        };
      };
    };
  };



  radicale =
  { resources, pkgs, ... }:
  {
    deployment = {
      targetEnv = "container";
      container.host = resources.machines.vps;
    };

    # FIXME put htpasswd in git crypt
    # FIXME need a git user config for radicale git hook in .git/config
    # [user]
    #   name = mickours
    #   email = contact@michaelmercier.fr

    services.radicale = {
      enable=true;
      config = ''
          [server]
          hosts = localhost:${builtins.toString radicalePort}

          [auth]
          type = htpasswd
          htpasswd_filename = ${radicaleCollection}/htpasswd
          htpasswd_encryption = bcrypt

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
  };



  mailserver =
  { resources, config, ... }:
  {
    deployment = {
      targetEnv = "container";
      container.host = resources.machines.vps;
    };

    networking.firewall.allowedTCPPorts = [ webPort webSslPort smtpSslPort imapSslPort ];

    imports = [
      (builtins.fetchTarball "https://github.com/r-raymond/nixos-mailserver/archive/v2.1.4.tar.gz")
    ];

    mailserver = {
      enable = true;
      fqdn = "mail.libr.fr";
      domains = [ "libr.fr" "michaelmercier.fr" ];

      loginAccounts = {
          "mickours@libr.fr" = {
              hashedPassword = "$6$JyR6AQ1j5RbDVw$bwcOX32dt16XRGtFuU6K.JHa1ekWac4Y/AlMZexH7CWA24sP32u1mPdpdjBpdsHApblG4Zn5wzMKmyh8Ipzw5.";
            aliases = [
              "info@libr.fr"
              "postmaster@libr.fr"
              "abuse@libr.fr"
            ];
            catchAll = [ "michaelmercier.fr" ];
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

    #services.nginx.enable = true;
    #services.nginx.virtualHosts = {
    #  "mail.libr.fr" = {
    #    # Manage self signe certificate
    #    forceSSL = true;
    #    enableACME = true;
    #    locations."/" = {
    #      root = "/var/www";
    #    };
    #  };
    #};
  };
}
