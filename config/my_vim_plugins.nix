{pkgs, vimPlugins, vimUtils}:
{
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
  ];

  dependencies = with pkgs; [
    # Vim config dependencies
    rustup
    go-langserver
    llvmPackages.libclang
    cquery
    # NOT WORKING DUE TO sha256 mismatch
    #(nur.repos.mic92.nix-lsp.overrideAttrs (attr: {
    #  cargoSha256 = "13fhaspvrgymbbr230j41ppbz3a5qm12xl667cs7x888h0jvsp5g";
    #}))
    (python3.withPackages(ps: with ps; [
      python-language-server
      # the following plugins are optional, they provide type checking, import sorting and code formatting
      pyls-mypy pyls-isort pyls-black jedi pylama
    ]))
  ];
}
