{ config, pkgs, ... }:
let
  my_dotfiles = builtins.fetchTarball "https://github.com/mickours/dotfiles/archive/master.tar.gz";
in
{
  environment.systemPackages = with pkgs; [
    ## Nix related
    nox
    nix-repl
    nix-prefetch-scripts
    nix-zsh-completions

    ## Admin tools
    # Storage
    ntfs3g
    exfat
    parted
    hdparm
    sysstat
    gsmartcontrol
    linuxPackages.perf
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
    unrar
    # Shell
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
    # Password
    gnupg
    #(pass.withExtensions (ext: [ext.pass-tomb]))
    rofi-pass
    # Misc
    cloc
    jq
    qemu

    ## Graphical environment
    # Gnome stuff
    # For system Monitor plugin
    gobjectIntrospection
    libgtop
    json_glib
    glib_networking
    chrome-gnome-shell

    # Fix Gnome crash
    gnome3.gjs
    # Web
    firefox
    # Dictionnaries
    aspellDicts.fr
    aspellDicts.en
    # Message and RSS
    qtox
    #skype
    tdesktop
    gnome3.polari
    liferea
    #rambox

    # Media
    vlc
    # Utils
    gnome3.gnome-disk-utility
    xorg.xkill
    wireshark-gtk

    ## Development environment
    gitAndTools.gitFull
    git-cola
    gitg
    python3
    python2
    gcc
    ctags
    gnumake
    wget
    cmake
    gdb
    direnv
    # Editors
    emacs
    neovim
    (callPackage ./my_vim.nix { my_vim_config = builtins.readFile("${my_dotfiles}/vimrc"); })
    # Web Site
    hugo
    # Graphic tools
    gcolor3
    graphviz
    imagemagick
    inkscape
    # Text/Tex/PDF
    entr
    pandoc
    rubber
    texlive.combined.scheme-small

    ## Pro
    cntlm
    opensc
    #libreoffice
    zotero

    ## Backups and sync
    python27Packages.syncthing-gtk
    transmission_gtk

    ## Printers
    saneBackends
    samsungUnifiedLinuxDriver

    ## Fun
    fortune
    sl
    wesnoth-dev
  ];
}
