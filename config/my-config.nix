# TODO merge this for local and VPN config
{ config, pkgs, ... }:
{
  programs = {
    # Enable system wide zsh and ssh agent
    zsh.enable = true;
    ssh.startAgent = true;

    bash = {
      enableCompletion = true;
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

  # Get ctrl+arrows works in nix-shell bash
  environment.etc."inputrc".text = builtins.readFile <nixpkgs/nixos/modules/programs/bash/inputrc> + ''
    "\e[A": history-search-backward
    "\e[B": history-search-forward
    set completion-ignore-case on
  '';


  users.extraUsers.mmercier = {
    description = "Michael Mercier";
    uid = 1000;
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    shell = pkgs.zsh;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRw1JgatpzemaR4EDkrlxwMEMzCpHfhR3Zum7ckS2hK1V5UADBe58AkCTJuPNdggzlnnlAj7fBBYKP4FfK4v+UHzvdk1FIiXHRv/ZGuZ+W881D7naWREKOyBMJAWSdn8cGvShptcsGJzLiAmH+G0AdZJKHLbn+h8rz3LaEad5XDJNtv37xo8b02e1l+lnxf4gAsgMh8Wt2bvLzVSqNh9jL72uNrQz0+p0ZY8mn0jpZ0u2cWqdLjGP99biCNdhn/hYe1nl6a3JjVDKPc+GDJsbfUotW8AYjIN3zk8IH3hZPbHVb1xTHHDOgBl9YXXJR8ezUehcHO+sB/7Ha+Nb7Katroq/zEm6O1s53YApkBcRfUu62v1RaCLhpDICTmWDzGvDYLYxHqPH6cgOOj91zLdabwq4WYLbQDOZWwIDVmJ6fPkQAnAuMl/kVuY96YjGZP7dtPiLj3cGmzIohOV6Cr+/qnW6D5xRCx1dCUZiE7/TGMyon3Oz6wlb1NMa1GY8U5Fg/QGMRzWe6KiLCthieoLDNonqK7gGv0KAObzFA8doNoqiiDMCc45GDJDK4o0RK7uWeYE1EdDODWnZXxThiXzsEXLecvfF+9kg3TeuaPdP1Ydel9O55yFWyRcztW+f/6yFrB/X0zmjN9rXDS3BSqn0UDSgpikDZHQvtcXlsinoTiQ== mmercier@oursbook"];
      };

  environment.systemPackages = with pkgs; [
    ## Nix related
    nox
    nix-prefetch-scripts
    nix-zsh-completions
    # Monitoring
    psmisc
    pmutils
    nmap
    htop
    usbutils
    iotop
    stress
    tcpdump
    # Files
    file
    tree
    ncdu
    unzip
    # Shell
    zsh
    vim
    tmux
    ranger
    # ranger previews
    libcaca   # video
    highlight # code
    atool     # archives
    w3m       # web
    poppler   # PDF
    mediainfo # audio and video
    ];
}
