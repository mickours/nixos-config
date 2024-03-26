{ pkgs, my_dotfiles, ... }:
let
  my_vim_config = builtins.readFile (builtins.toPath "${my_dotfiles}/vimrc");
  my_tmux_config = builtins.readFile (builtins.toPath "${my_dotfiles}/tmux.conf");
  my_zsh_config = builtins.readFile (builtins.toPath "${my_dotfiles}/zshrc.local");
  my_zellij_config = builtins.readFile (builtins.toPath "${my_dotfiles}/config/zellij/config.kdl");
  my_vim_plugins = pkgs.callPackage ./my_vim_plugins.nix { };
in
{
  home.stateVersion = "23.11";
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
        nil
      ] ++ my_vim_plugins.dependencies;
      extraPython3Packages = (ps: with ps; [ jedi ]);

      # coc
      withNodeJs = true;
      coc.enable = true;
      coc.settings = {
        "python.formatting.provider" = "black";
        "coc.preferences.formatOnType" = true;
        "coc.preferences.formatOnSaveFiletypes" = [ "python" ];
        "python.pythonPath" = "nvim-python3";
        "languageserver" = {
          "nix" = {
            "command" = "nil";
            "filetypes" = [ "nix" ];
            "rootPatterns" = [ "flake.nix" ];
          };
          "python" = {
            "command" = "pyls";
            "args" = [
              "--log-file"
              "/tmp/lsp_python.log"
            ];
            "trace.server" = "verbose";
            "filetypes" = [
              "python"
            ];
            "settings" = {
              "pyls" = {
                "enable" = true;
                "trace" = {
                  "server" = "verbose";
                };
                "commandPath" = "";
                "configurationSources" = [
                  "pycodestyle"
                ];
                "plugins" = {
                  "jedi_completion" = {
                    "enabled" = true;
                  };
                  "jedi_hover" = {
                    "enabled" = true;
                  };
                  "jedi_references" = {
                    "enabled" = true;
                  };
                  "jedi_signature_help" = {
                    "enabled" = true;
                  };
                  "jedi_symbols" = {
                    "enabled" = true;
                    "all_scopes" = true;
                  };
                  "mccabe" = {
                    "enabled" = true;
                    "threshold" = 15;
                  };
                  "preload" = {
                    "enabled" = true;
                  };
                  "pycodestyle" = {
                    "enabled" = true;
                  };
                  "pydocstyle" = {
                    "enabled" = false;
                    "match" = "(?!test_).*\\.py";
                    "matchDir" = "[^\\.].*";
                  };
                  "pyflakes" = {
                    "enabled" = true;
                  };
                  "rope_completion" = {
                    "enabled" = true;
                  };
                  "black" = {
                    "enabled" = true;
                  };
                };
              };
            };
          };
        };
      };
    };
    tmux.enable = true;
    tmux.extraConfig = my_tmux_config;
    zsh.enable = true;
    zsh.dotDir = ".config/zsh";
    zsh.initExtraBeforeCompInit = builtins.readFile ./zshrc;
    zsh.initExtra = my_zsh_config;
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

  services.syncthing.enable = true;
}
