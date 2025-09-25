{ pkgs, dotfiles, adrienPkgs }:

with pkgs;
let
  my_vim_plugins = pkgs.callPackage ./my_vim_plugins.nix { };
in
{
  common = [
    # nix_utils
    nix-prefetch-scripts
    nix-zsh-completions
    # monitoring
    psmisc
    pmutils
    nmap
    htop
    usbutils
    iotop
    stress
    tcpdump
    lsof
    # files
    file
    tree
    ncdu
    unzip
    dosfstools
    # unrar #NOT FREE need allowUnfree set to true
    # tools
    zsh
    tmux
    ranger
    # ranger previews
    libcaca # video
    highlight # code
    atool # archives
    w3m # web
    poppler # PDF
    mediainfo # audio and video
  ] ++ my_vim_plugins.dependencies;

  graphical = [
    # Gnome stuff
    gnomeExtensions.system-monitor-next
    gnomeExtensions.battery-health-charging
    evolution
    evolution-data-server
    gnome-firmware-updater
    gnome-tweaks

    # Web
    firefox
    chrome-gnome-shell
    chromium

    # Dictionnaries
    aspellDicts.fr
    aspellDicts.en
    # Message and RSS
    signal-desktop

    # Media
    vlc
    gthumb
    obs-studio
    # Utils
    gnome-disk-utility
    xorg.xkill
    deja-dup
    mesa-demos
    git-cola
    gitg
    pdftk

    # storage
    ntfs3g
    exfat
    parted
    hdparm
    sysstat
    gsmartcontrol
    linuxPackages.perf
    # Password
    gnupg
    wl-clipboard

    # Writings
    calibre
    libreoffice-fresh

    # Graphic tools
    gcolor3
    graphviz
    imagemagick
    inkscape
    gimp
  ];

  development =
    let
      RStudio-with-my-packages = rstudioWrapper.override {
        packages = with rPackages; [ tidyverse snakecase ];
      };
    in
    [
      gitAndTools.gitFull
      python3
      poetry
      gotop
      gcc
      ctags
      gnumake
      wget
      cmake
      gdb
      direnv
      entr
      pandoc
      socat
      bind
      bat
      zsh-powerlevel10k
      meld
      smem
      eza
      ripgrep
      zoxide
      lsd
      lazygit
      dogdns
      httpie
      gtop
      glances
      cheat
      fzf
      fd
      broot
      duf
      du-dust
      delta
      nnn
      zellij
      bandwhich
      sniffnet
      pigz
      # Day to day use in Ryax
      bitwarden
      ts
      kind
      cachix
      kubernetes-helm
      helmfile
      helm-docs
      kubectl
      pssh
      awscli2
      (
        google-cloud-sdk.withExtraComponents (
          [ google-cloud-sdk.components.gke-gcloud-auth-plugin ]
        )
      )
      docker-compose
      eksctl
      skopeo
      cri-tools
      azure-cli
      kubelogin
      yarn
      RStudio-with-my-packages
      ruff
      velero
      scaleway-cli
      opentofu
      openssl
      jetbrains.pycharm-professional
      uv
      adrienPkgs.cgvg-rs

      # Editors
      emacs
      # Web Site
      hugo
      # Misc
      cloc
      jq
      qemu
      # printers
      sane-backends
      samsung-unified-linux-driver
      hplipWithPlugin
      # fun
      fortune
      sl
      wesnoth-dev
    ];
}
