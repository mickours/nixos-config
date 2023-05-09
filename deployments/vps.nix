{ config, pkgs, lib, ... }:
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

  system.stateVersion = "22.11";

  time.timeZone = "Europe/Paris";

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
    dkimKeyDirectory = "/data/dkim";
  };

  ##***************#
  ##   NextCloud   #
  ##***************#

  services.nextcloud = {
    enable = true;
    package = pkgs.nextcloud25;
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
  };

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
    ] ++ pkgs_lists.common;
}
