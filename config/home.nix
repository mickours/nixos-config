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
in
{
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

      # coc
      withNodeJs = true;
      coc.enable = true;
      # bug: neovim: rebuilding with coc support does not work when nodejs is in PATH
      # https://github.com/nix-community/home-manager/issues/2966
      # Solution:
      # https://github.com/sumnerevans/home-manager-config/commit/da138d4ff3d04cddb37b0ba23f61edfb5bf7b85e
      coc.package = pkgs.vimUtils.buildVimPluginFrom2Nix {
        pname = "coc.nvim";
        version = "2022-05-21";
        src = pkgs.fetchFromGitHub {
          owner = "neoclide";
          repo = "coc.nvim";
          rev = "791c9f673b882768486450e73d8bda10e391401d";
          sha256 = "sha256-MobgwhFQ1Ld7pFknsurSFAsN5v+vGbEFojTAYD/kI9c=";
        };
        meta.homepage = "https://github.com/neoclide/coc.nvim/";
      };
      coc.settings = {
        "python.formatting.provider" = "black";
        "coc.preferences.formatOnType" = true;
        "coc.preferences.formatOnSaveFiletypes" = ["python"];
        "python.pythonPath" = "nvim-python3";
        "languageserver" = {
          "nix" = {
            "command" = "rnix-lsp";
            "filetypes" = ["nix"];
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
  };
  # Zsh extra config
  home.file.".p10k.zsh".text = builtins.readFile ./p10k.zsh;

  # Vim extra config
  xdg.configFile."nvim/coc-settings.json".text =
    builtins.readFile ./coc-settings.json;

  services.syncthing.enable = true;
}
