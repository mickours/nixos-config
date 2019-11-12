{ pkgs ? import <nixpkgs-unstable> {} }:
with pkgs;
let
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
    coc-nvim
    coc-python
    coc-yaml
    coc-json
    coc-html
    coc-css
  ];

  my_dotfiles = builtins.fetchGit {
    url = https://github.com/mickours/dotfiles;
    ref = "master";
    rev = "dfce2b15b8ccb4a91f4d459cb0dfa9cd5888c4ee";
  };

  my_vim_config = builtins.readFile("${my_dotfiles}/vimrc");
in
(vim_configurable.customize {
    name = "v";
    # add my custom .vimrc
    vimrcConfig.customRC = my_vim_config + ''
    '';
    vimrcConfig.plug.plugins = plugins;
    #vimrcConfig.packages.myVimPackage = {
    #    # loaded on launch
    #    start = plugins;
    #    # manually loadable by calling `:packadd $plugin-name`
    #    opt = [  ];
    #    # To automatically load a plugin when opening a filetype, add vimrc lines like:
    #    # autocmd FileType php :packadd phpCompletion
    #};
  }
)

