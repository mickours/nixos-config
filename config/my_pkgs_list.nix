{ pkgs }:

with pkgs;
let
  my_dotfiles = builtins.fetchGit {
    url = https://github.com/mickours/dotfiles;
    ref = "master";
    rev = "780e928e6cefc6639a80fffd9217c98d6d442fa3";
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
      vimrcConfig.customRC = my_vim_config + my_vim_plugins.extraConfig + ''
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
    rambox

    # Media
    vlc
    # Utils
    gnome3.gnome-disk-utility
    xorg.xkill
    wireshark-qt
    git-cola
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
