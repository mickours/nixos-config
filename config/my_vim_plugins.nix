{pkgs, vimPlugins, vimUtils}:
let
  customPlugins = {
    autocomplpop = vimUtils.buildVimPlugin {
      name = "vim-autocomplpop-2.14.1";
      src = fetchTarball https://github.com/vim-scripts/AutoComplPop/archive/2.14.1.tar.gz;
    };
    vim-sublime-monokai = vimUtils.buildVimPlugin {
      name = "vim-sublime-monokai-2.0";
      src = fetchTarball https://github.com/ErichDonGubler/vim-sublime-monokai/archive/master.tar.gz;
    };
  };
in
{
  plugins = with vimPlugins; [
    fugitive
    ctrlp
    airline
    Syntastic
    gitgutter
    The_NERD_tree
    The_NERD_Commenter
    vim-easytags
    vim-misc
    LanguageClient-neovim
    Tagbar
    vim-orgmode
    multiple-cursors
    gundo
    vim-nix
    vim-autoformat
    vim-go
    tmux-navigator
    rainbow_parentheses
    vim-trailing-whitespace
    vim-grammarous
    csv
    molokai
    fzf-vim
    # custom plugins
    customPlugins.vim-sublime-monokai
    customPlugins.autocomplpop
  ];
  dependencies = with pkgs; [
    # Vim config dependencies
    fzf
    rustup
    go-langserver
    llvmPackages.libclang
    # nur.repos.mic92.nix-lsp # NOT WORKING DUE TO sha256 mismatch
    (python3.withPackages(ps: [
      ps.python-language-server
      # the following plugins are optional, they provide type checking, import sorting and code formatting
      ps.pyls-mypy ps.pyls-isort ps.pyls-black
    ]))
  ];
}
