{ pkgs }:

let
  my_dotfiles = builtins.fetchTarball "https://github.com/mickours/dotfiles/archive/master.tar.gz";
in
with pkgs;
#{
#  pkgs_lists =
#  {
    # common.nix_utils = [
[
      nix-prefetch-scripts
      nix-zsh-completions
    # ];

    # common.monitoring = [
      psmisc
      pmutils
      nmap
      htop
      usbutils
      iotop
      stress
      tcpdump
    # ];
    # common.files = [
      file
      tree
      ncdu
      unzip
      unrar
    # ];
    # common.shell_navigation = [
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
    # ];

    # storage = [
      ntfs3g
      exfat
      parted
      hdparm
      sysstat
      gsmartcontrol
      linuxPackages.perf
    # ];


    # passwords = [
      # Password
      gnupg
      #(pass.withExtensions (ext: [ext.pass-tomb]))
      rofi-pass
    # ];
    # extra = [
      cloc
      jq
      qemu
    # ];

    # graphical.common = [
      # Gnome stuff
      # For system Monitor plugin
      gobjectIntrospection
      libgtop
      json_glib
      glib_networking
      chrome-gnome-shell

      # Web
      firefox
      # Dictionnaries
      aspellDicts.fr
      aspellDicts.en
      # Message and RSS
      #qtox
      #skype
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
    # ];

    # graphical.office = [
      # Graphic tools
      gcolor3
      graphviz
      imagemagick
      inkscape
      libreoffice
      # Reasearch
      zotero
      # Text/Tex/PDF
      rubber
      texlive.combined.scheme-small
    # ];


    # development =
    #[
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
      (callPackage ./my_vim.nix { my_vim_config = builtins.readFile("${my_dotfiles}/vimrc"); })
      # Web Site
      hugo
    #];

    #backups_and_sync = [
      python27Packages.syncthing-gtk
      transmission_gtk
    #];

    #printers = [
      saneBackends
      samsungUnifiedLinuxDriver
    #];

    #fun = [
      fortune
      sl
      wesnoth-dev
    #];
  #};
#}
]
