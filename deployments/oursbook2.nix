{ config,
  pkgs ? import ../nixpkgs { },
  lib,
  ...
}:
rec {
  networking.hostName = "oursbook2";

  system.stateVersion = 19.03;

  nix.nixPath = [
        "nixpkgs=/nix/var/nix/profiles/per-user/root/channels/nixos/nixpkgs"
        "nixos-config=/etc/nixos/configuration.nix"
        "/nix/var/nix/profiles/per-user/root/channels"
        "kapack=${builtins.toPath /home/mmercier/Projects/kapack}"
  ];

  imports = [
    ./oursbook2-hardware-configuration.nix
    ../modules/common.nix
    ../modules/development.nix
    ../modules/graphical.nix
  ];

  environments.mickours.common = {
    enable = true;
    keyFiles = [
      ./keys/id_rsa_oursbook.pub
      ./keys/id_rsa_roggy.pub
    ];
  };

  environments.mickours.graphical.enable = true;
  environments.mickours.graphical.myuser = "mmercier";
  environments.mickours.development.enable = true;

  #### TOREMOVE

  #  #environment.systemPackages = pkgs_lists.common;

  #  # use Vim by default
  #  environment.sessionVariables.EDITOR="v";
  #  environment.sessionVariables.VISUAL="v";
  #  environment.shellAliases = {
  #    "vim"="v";
  #  };

  #  # Keyboard and locale support
  #  i18n = {
  #    consoleKeyMap = "fr";
  #    #defaultLocale = "en_US.UTF-8";
  #  };

  #  programs = {
  #  # Enable system wide zsh and ssh agent
  #    zsh.enable = true;
  #    ssh.startAgent = true;

  #    bash = {
  #      enableCompletion = true;
  #      # Make shell history shared and saved at each command
  #      interactiveShellInit = ''
  #        shopt -s histappend
  #        PROMPT_COMMAND="history -n; history -a"
  #        unset HISTFILESIZE
  #        HISTSIZE=5000
  #      '';
  #    };
  #    # Whether interactive shells should show which Nix package (if any)
  #    # provides a missing command.
  #    command-not-found.enable = true;
  #  };

  #  # Make sudo funnier!
  #  #security.sudo.extraConfig = ''
  #  #    Defaults   insults
  #  #'';
  #  nixpkgs.config.packageOverrides = pkgs:
  #  {
  #    sudo = pkgs.sudo.override { withInsults = true; };
  #  };

  #  # Get ctrl+arrows works in nix-shell bash
  #  environment.etc."inputrc".text = builtins.readFile <nixpkgs/nixos/modules/programs/bash/inputrc> + ''
  #    "\e[A": history-search-backward
  #    "\e[B": history-search-forward
  #    set completion-ignore-case on
  #  '';

  #  # Avoid journald to store GigaBytes of logs
  #  services.journald.extraConfig = ''
  #    SystemMaxUse=1G
  #  '';

  #  # Add my user
  #  users.extraUsers.mmercier = {
  #    description = "Michael Mercier";
  #    isNormalUser = true;
  #    extraGroups = [ "wheel" ];
  #    shell = pkgs.zsh;
  #    #openssh.authorizedKeys.keyFiles = cfg.keyFiles;
  #  };
  #### TOREMOVE

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Add virtualbox and docker
  virtualisation = {
    virtualbox.host.enable = true;
    docker.enable = true;
    docker.extraOptions = "--insecure-registry registry.ryax.local:80";
    docker.enableNvidia = true;
    libvirtd.enable = true;
  };

  # Add docker and libvirt users
  users.extraUsers.mmercier.extraGroups = [ "docker" "libvirtd" ];

  environment.systemPackages = with pkgs; [
    lm_sensors
    pass
    gnomeExtensions.gsconnect
    linuxPackages_latest.acpi_call

    #libreoffice
    zotero
    gnome3.pomodoro
  ];

  # Ryax related
  services.zerotierone = {
      enable = true;
      joinNetworks = ["8267aa80ea375ab2"]; # One of these has a managed route
    };

  networking.firewall.enable = false;
  networking.extraHosts =
  ''
    127.0.0.1 ryax.local api.ryax.local registry.ryax.local monitor.ryax.local
  '';
  #security.pki.certificateFiles = [ /home/mmercier/certs/domain.crt ];
}

