{ pkgs, my_dotfiles, ... }:
let
  my_vim_config = builtins.readFile (builtins.toPath "${my_dotfiles}/vimrc");
  my_tmux_config =
    builtins.readFile (builtins.toPath "${my_dotfiles}/tmux.conf");
  my_zsh_config =
    builtins.readFile (builtins.toPath "${my_dotfiles}/zshrc.local");
  my_zellij_config = builtins.readFile
    (builtins.toPath "${my_dotfiles}/config/zellij/config.kdl");
  my_vim_plugins = pkgs.callPackage ./my_vim_plugins.nix { };
in {
  home.stateVersion = "25.05";
  home.packages = with pkgs; [ zsh-powerlevel10k meslo-lgs-nf ];

  # Bluetooth command for headsets
  systemd.user.services.mpris-proxy = {
    Unit.Description = "Mpris proxy";
    Unit.After = [ "network.target" "sound.target" ];
    Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    Install.WantedBy = [ "default.target" ];
  };
  programs = {
    helix = {
      enable = true;
      extraPackages = with pkgs; [ nil ruff ];
      settings = {
        theme = "autumn_night_transparent";
        editor.cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
      };
      languages.language-server.typescript-language-server =
        with pkgs.nodePackages; {
          command =
            "${typescript-language-server}/bin/typescript-language-server";
          args = [
            "--stdio"
            "--tsserver-path=${typescript}/lib/node_modules/typescript/lib"
          ];
        };
      languages.language-server.nil = {
        command = "${pkgs.nil}/bin/nil";
        config = { rootPatterns = [ "flake.nix" ]; };
      };
      languages.language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          file-types = [ "nix" ];
        }
        {
          name = "python";
          auto-format = true;
        }
      ];
      themes = {
        autumn_night_transparent = {
          "inherits" = "autumn_night";
          "ui.background" = { };
        };
      };
    };
    neovim = {
      enable = true;
      withPython3 = true;
      extraConfig = my_vim_config;
      plugins = my_vim_plugins.plugins;
      extraPackages = with pkgs;
        [
          (python3.withPackages (ps: with ps; [ black flake8 jedi pylyzer ]))
          nil
          ruff
          pylyzer
        ] ++ my_vim_plugins.dependencies;
      extraPython3Packages = (ps: with ps; [ jedi ]);

      # coc
      withNodeJs = true;
      coc.enable = true;
      coc.settings = {
        "coc.preferences.formatOnType" = true;
        "coc.preferences.formatOnSaveFiletypes" = [ "python" ];
        "python.pythonPath" = "nvim-python3";
        "languageserver" = {
          "nix" = {
            "command" = "nil";
            "filetypes" = [ "nix" ];
            "rootPatterns" = [ "flake.nix" ];
          };
          "ruff-lsp" = {
            "command" = "ruff-lsp";
            "filetypes" = [ "python" ];
          };
          "pylyzer" = {
            "command" = [ "pylyzer" "--server" ];
            "filetypes" = [ "python" ];
          };
        };
      };
    };
    tmux.enable = true;
    tmux.extraConfig = my_tmux_config;
    zsh.enable = true;
    zsh.dotDir = ".config/zsh";
    zsh.initContent = (builtins.readFile ./zshrc) + my_zsh_config;
    git = {
      enable = true;
      userName = "Michael Mercier";
    };
    # Modern teminal tools
    fzf.enable = true;
    fzf.enableZshIntegration = true;
    zellij.enable = true;
    lf.enable = true;
    eza.enable = true;
    lazygit.enable = true;
    ripgrep.enable = true;
  };
  # Zsh extra config
  home.file.".p10k.zsh".text = builtins.readFile ./p10k.zsh;
  # Zellij config
  home.file.".config/zellij/config.kdl".text = my_zellij_config;

  # Fix browserpass
  home.file.".mozilla/native-messaging-hosts/com.github.browserpass.native.json".source =
    "${pkgs.browserpass}/lib/mozilla/native-messaging-hosts/com.github.browserpass.native.json";
  home.file.".mozilla/native-messaging-hosts/org.gnome.chrome_gnome_shell.json".source =
    "${pkgs.chrome-gnome-shell}/lib/mozilla/native-messaging-hosts/org.gnome.chrome_gnome_shell.json";

  services.syncthing.enable = true;
}
