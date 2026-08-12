{
  pkgs,
  dotfiles,
  adrienPkgs,
}:

with pkgs;
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
    yazi
    scooter
    helix
    gemini-cli
  ];

  graphical = [
    # Gnome stuff
    gnomeExtensions.system-monitor-next
    evolution
    evolution-data-server
    gnome-firmware
    gnome-tweaks

    # Web
    firefox
    gnome-browser-connector
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
    deja-dup
    mesa-demos
    gitg
    pdftk

    # storage
    ntfs3g
    exfat
    parted
    hdparm
    sysstat
    gsmartcontrol
    perf
    # Password
    gnupg
    wl-clipboard

    # Writings
    ((calibre.override { unrarSupport = true; }).overrideAttrs { installCheckPhase = ""; })
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
        packages = with rPackages; [
          tidyverse
          snakecase
        ];
      };
    in
    [
      gitFull
      git-lfs
      python3
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
      eza
      ripgrep
      lsd
      lazygit
      gtop
      fzf
      delta
      zellij
      bandwhich
      pigz
      heimdall
      # Day to day use in Ryax
      # bitwarden-desktop # Depends on EOL Electron
      ts
      kind
      cachix
      kubernetes-helm
      helmfile
      helm-docs
      kubectl
      pssh
      awscli2
      (google-cloud-sdk.withExtraComponents ([ google-cloud-sdk.components.gke-gcloud-auth-plugin ]))
      docker-compose
      eksctl
      skopeo
      cri-tools
      azure-cli
      kubelogin
      yarn
      # Broken in 25.11
      # RStudio-with-my-packages
      ruff
      velero
      scaleway-cli
      opentofu
      openssl
      jetbrains.pycharm
      uv
      adrienPkgs.rgvg

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
      # fun
      fortune
      sl
    ];
}
