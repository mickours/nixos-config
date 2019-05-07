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

  # Use LTS kernel
  boot.kernelPackages = pkgs.linuxPackages_4_9;

  # Add virtualbox and docker
  virtualisation = {
    virtualbox.host.enable = true;
    docker.enable = true;
    docker.extraOptions = "--insecure-registry registry.myryax.minikube:80";
    libvirtd.enable = true;
  };

  environment.systemPackages = with pkgs; [
    lm_sensors
    pass
    gnomeExtensions.gsconnect

    #libreoffice
    zotero
    gnome3.pomodoro
  ];

  networking.firewall.enable = false;
  networking.extraHosts =
  ''
    192.168.39.206 myryax.minikube
    192.168.39.206 api.myryax.minikube
    192.168.39.206 registry.myryax.minikube
  '';
}

