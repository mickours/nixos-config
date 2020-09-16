{ pkgs }:

with pkgs;
let
  my_dotfiles = builtins.fetchGit {
    url = https://github.com/mickours/dotfiles;
    ref = "master";
    rev = "f7ee7368682e4b8b319344be009034443602e228";
  };
  my_vim_config = builtins.readFile(builtins.toPath "${my_dotfiles}/vimrc");
  my_vim_plugins = pkgs.callPackage ./my_vim_plugins.nix {};
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
    # unrar #NOT FREE need allowUnfree set to true
    # tools
    zsh
    tmux
    ranger
    # ranger previews
    libcaca   # video
    highlight # code
    atool     # archives
    w3m       # web
    poppler   # PDF
    mediainfo # audio and video
    ((vim_configurable.override { python = python3; }).customize {
      name = "v";
      # add my custom .vimrc
      vimrcConfig.customRC = my_vim_config + ''
      '';
      vimrcConfig.packages.myVimPackage = {
          # loaded on launch
          start = my_vim_plugins.plugins;
          # manually loadable by calling `:packadd $plugin-name`
          opt = [  ];
          # To automatically load a plugin when opening a filetype, add vimrc lines like:
          # autocmd FileType php :packadd phpCompletion
      };
    })
    (neovim.override {
      configure = {
        packages.myVimPackage = {
          # see examples below how to use custom packages
          start = my_vim_plugins.plugins;
          opt = [ ];
        };
      };
    })
  ] ++ my_vim_plugins.dependencies;

  graphical = [
    # Gnome stuff
    gnomeExtensions.system-monitor
    gnome3.evolution
    evolution-data-server
    gnome-firmware-updater

    # Web
    firefox
    chrome-gnome-shell
    # Dictionnaries
    aspellDicts.fr
    aspellDicts.en
    # Message and RSS
    skype
    gnome3.polari
    liferea

    # Media
    vlc
    gthumb
    obs-studio
    obs-wlrobs
    # Utils
    gnome3.gnome-disk-utility
    xorg.xkill
    wireshark-qt
    git-cola
    gitg
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
    rofi-pass

    # Graphic tools
    gcolor3
    graphviz
    imagemagick
    inkscape
    #libreoffice-fresh
    gimp
  ];

  development =
  [
    gitAndTools.gitFull
    python3
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
    # Day to day use in Ryax
    cachix
    kubernetes-helm
    kubectl
    k9s
    pssh
    # Editors
    emacs
    # Web Site
    hugo
    # Misc
    cloc
    jq
    qemu
    # printers
    saneBackends
    samsungUnifiedLinuxDriver
    hplipWithPlugin
    # fun
    fortune
    sl
    wesnoth-dev
  ];
}
