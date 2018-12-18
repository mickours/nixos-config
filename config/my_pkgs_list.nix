{ pkgs }:

with pkgs;
let
  my_dotfiles = builtins.fetchTarball "https://github.com/mickours/dotfiles/archive/master.tar.gz";
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
    # my vim config
    (pkgs.callPackage ./my_vim.nix {
      my_vim_config = builtins.readFile("${my_dotfiles}/vimrc");
      vim_configurable = vim_configurable.override { python = python3; };
    })
    (python3.withPackages(ps: [
      ps.python-language-server
      # the following plugins are optional, they provide type checking, import sorting and code formatting
      ps.pyls-mypy ps.pyls-isort ps.pyls-black
    ]))
  ];

  graphical = [
    # Gnome stuff
    # For system Monitor plugin
    gnomeExtensions.system-monitor
    #gobjectIntrospection
    #libgtop
    #json_glib
    #glib_networking

    # Web
    firefox
    chrome-gnome-shell
    # Dictionnaries
    aspellDicts.fr
    aspellDicts.en
    # Message and RSS
    qtox
    skype
    #tdesktop
    gnome3.polari
    liferea
    rambox

    # Media
    vlc
    # Utils
    gnome3.gnome-disk-utility
    xorg.xkill
    wireshark-gtk
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
    libreoffice-fresh
    gimp
  ];

  development =
  [
    gitAndTools.gitFull
    python3
    python2
    gcc
    ctags
    gnumake
    wget
    cmake
    gdb
    direnv
    entr
    pandoc
    # Editors
    emacs
    neovim
    # Web Site
    hugo
    # Misc
    cloc
    jq
    qemu
    # printers
    saneBackends
    samsungUnifiedLinuxDriver
    # fun
    fortune
    sl
    wesnoth-dev
  ];
}
