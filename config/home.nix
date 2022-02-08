{ pkgs, ... }:
let
    my_dotfiles = builtins.fetchGit {
      url = "https://github.com/mickours/dotfiles";
      ref = "master";
      rev = "e6619f1dacb330dd66a6e60631eacc109f25d237";
    };
    my_vim_config = builtins.readFile (builtins.toPath "${my_dotfiles}/vimrc");
    my_tmux_config = builtins.readFile (builtins.toPath "${my_dotfiles}/tmux.conf");
    my_zsh_config = builtins.readFile (builtins.toPath "${my_dotfiles}/zshrc.local");
    my_vim_plugins = pkgs.callPackage ./my_vim_plugins.nix { };
in {
  home.packages = with pkgs; [ zsh-powerlevel10k meslo-lgs-nf ];

  # Bluetooth command for headsets
  systemd.user.services.mpris-proxy = {
    Unit.Description = "Mpris proxy";
    Unit.After = [ "network.target" "sound.target" ];
    Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    Install.WantedBy = [ "default.target" ];
  };
  programs = {
    neovim = {
      enable = true;
      withPython3 = true;
      extraConfig = my_vim_config;
      plugins = my_vim_plugins.plugins;
      extraPackages = with pkgs; [
        (python3.withPackages (ps: with ps; [ black flake8 jedi ]))
        rnix-lsp
      ] ++ my_vim_plugins.dependencies;
      extraPython3Packages = (ps: with ps; [ jedi ]);
    };
    tmux.enable = true;
    tmux.extraConfig = my_tmux_config;
    zsh.enable = true;
    zsh.dotDir = ".config/zsh";
    zsh.initExtraBeforeCompInit = builtins.readFile ./zshrc;
    zsh.initExtra = my_zsh_config;
    git = {
      enable = true;
      userName  = "Michael Mercier";
    };
  };
  # Zsh extra config
  home.file.".p10k.zsh".text = builtins.readFile ./p10k.zsh;

  # Vim extra config
  xdg.configFile."nvim/coc-settings.json".text =
    builtins.readFile ./coc-settings.json;

  services.syncthing.enable = true;
}
