let
  nixpkgs-stable = (fetchTarball "https://github.com/NixOS/nixpkgs/archive/18.03.tar.gz");
in
{
  network.description = "Michael Mercier Personal Network";

  vps =
  { config, pkgs, ... }:
  let
    radicaleCollection = "/data/radicale";
  in
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

    networking.firewall.allowedTCPPorts = [ 5232 80 443 ];

    # State problem
    # FIXME put htpasswd in git crypt
    # FIXME need a git user config for radicale git hook in .git/config
    # [user]
    #   name = mickours
    #   email = contact@michaelmercier.fr

    services.radicale = {
      enable=true;
      config = ''
          [server]
          hosts = localhost:5232

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
          proxyPass = "http://localhost:5232/";
          extraConfig = ''
            proxy_set_header     X-Script-Name /radicale;
            proxy_set_header     X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header     X-Remote-User $remote_user;
          '';
        };
      };
      ##"mail.libr.fr" = {
      #  # Manage self signe certificate
      #  forceSSL = true;
      #  enableACME = true;
      #  locations."/" = {
      #    root = "/var/www";
      #  };
      #};
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

  mailserver =
  { resources, ... }:
  {
    deployment = {
      targetEnv = "container";
      container.host = resources.machines.vps;
    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];

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

      enableImapSsl = true;
      enablePop3Ssl = true;

      # Use Let's Encrypt certificates. Note that this needs to set up a stripped
      # down nginx and opens port 80.
      certificateScheme = 3;
    };

    services.nginx.enable = true;
    services.nginx.virtualHosts = {
      "mail.libr.fr" = {
        # Manage self signe certificate
        forceSSL = true;
        enableACME = true;
        locations."/" = {
          root = "/var/www";
        };
      };
    };
  };
}
