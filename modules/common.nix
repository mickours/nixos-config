{ config, lib, pkgs, modulesPath, inputs, ... }:
let
  pkgs_lists = import ../config/my_pkgs_list.nix { inherit pkgs; dotfiles = inputs.my_dotfiles; };
  cfg = config.environments.mickours.common;
in
with lib; {
  options.environments.mickours.common = {
    enable = mkEnableOption "common";
    keyFiles = mkOption {
      type = types.listOf types.path;
      default = [ ];
      example = [ ];
      description = ''
        The list of Ssh keys allowed to log.
      '';
    };
  };

  config = mkIf config.environments.mickours.common.enable {
    environment.systemPackages = pkgs_lists.common;

    # use NeoVim by default
    environment.sessionVariables.EDITOR = "nvim";
    environment.sessionVariables.VISUAL = "nvim";
    environment.shellAliases = {
      "vim" = "nvim";
      "v" = "vim";
    };

    # Keyboard and locale support
    console.keyMap = "fr";
    i18n = {
      defaultLocale = "en_US.UTF-8";
      extraLocaleSettings = { LC_MESSAGES = "en_US.UTF-8"; LC_TIME = "fr_FR.UTF-8"; };
      inputMethod.ibus.engines = with pkgs.ibus-engines; [ typing-booster ];
    };

    programs = {
      # Enable system wide zsh and ssh agent
      zsh.enable = true;
      zsh.interactiveShellInit = ''
        source ${pkgs.grml-zsh-config}/etc/zsh/zshrc
        source ${pkgs.zsh-powerlevel10k}/share/zsh-powerlevel10k/powerlevel10k.zsh-theme
      '';
      zsh.promptInit = ""; # otherwise it'll override the grml prompt

      ssh.startAgent = true;
      gnupg.agent.enable = true;

      bash = {
        completion.enable = true;
        # Make shell history shared and saved at each command
        interactiveShellInit = ''
          shopt -s histappend
          PROMPT_COMMAND="history -n; history -a"
          unset HISTFILESIZE
          HISTSIZE=5000
        '';
      };
      # Whether interactive shells should show which Nix package (if any)
      # provides a missing command.
      command-not-found.enable = true;
    };

    # Make sudo funnier!
    #security.sudo.extraConfig = ''
    #    Defaults   insults
    #'';
    nixpkgs.config.packageOverrides = pkgs: {
      sudo = pkgs.sudo.override { withInsults = true; };
    };

    # Get ctrl+arrows works in nix-shell bash
    environment.etc."inputrc".text =
      builtins.readFile (modulesPath + "/programs/bash/inputrc") + ''
        "\e[A": history-search-backward
        "\e[B": history-search-forward
        set completion-ignore-case on
      '';

    # Avoid journald to store GigaBytes of logs
    services.journald.extraConfig = ''
      SystemMaxUse=1G
    '';

    # Alernate DNS resolution server to avoid French website blocking
    networking.nameservers = [ "1.1.1.1" "9.9.9.9" ];

    # Allow usage of not wrapped binaries
    programs.nix-ld.enable = true;

    programs.nix-ld.libraries = with pkgs; [
      stdenv.cc.cc
      zlib
      openssl
    ];

    # Add my user
    users.extraUsers.mmercier = {
      description = "Michael Mercier";
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keyFiles = cfg.keyFiles;
    };
  };
}
