{ pkgs ? import <nixpkgs> {} }:
with pkgs;
let
  customPlugins = {
    autocomplpop = vimUtils.buildVimPlugin {
      name = "vim-autocomplpop-2.14.1";
      src = fetchTarball https://github.com/vim-scripts/AutoComplPop/archive/2.14.1.tar.gz;
    };
    vim-sublime-monokai = vimUtils.buildVimPlugin {
      name = "vim-sublime-monokai-master";
      src = fetchTarball https://github.com/ErichDonGubler/vim-sublime-monokai/archive/master.tar.gz;
    };
  };

  plugins = with vimPlugins; [
    fugitive
    ctrlp
    airline
    Syntastic
    gitgutter
    The_NERD_tree
    The_NERD_Commenter
    LanguageClient-neovim
    Tagbar
    vim-gutentags
    vim-orgmode
    multiple-cursors
    vim-nix
    vim-autoformat
    vim-go
    tmux-navigator
    rainbow_parentheses
    vim-trailing-whitespace
    vim-grammarous
    csv
    gruvbox
    # custom plugins
    customPlugins.vim-sublime-monokai
    customPlugins.autocomplpop
  ];

  my_dotfiles = builtins.fetchGit {
    url = https://github.com/mickours/dotfiles;
    ref = "master";
    rev = "9493e5dc8162c596ac21a3fdd3a73a955a9cb825";
  };

  my_vim_config = builtins.readFile("${my_dotfiles}/vimrc");
in
(vim_configurable.customize {
    name = "v";
    # add my custom .vimrc
    vimrcConfig.customRC = my_vim_config + ''
    '';
    vimrcConfig.packages.myVimPackage = {
        # loaded on launch
        start = plugins;
        # manually loadable by calling `:packadd $plugin-name`
        opt = [  ];
        # To automatically load a plugin when opening a filetype, add vimrc lines like:
        # autocmd FileType php :packadd phpCompletion
    };
  }
)

