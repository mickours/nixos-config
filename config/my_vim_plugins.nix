{pkgs, vimPlugins, vimUtils}:
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
    fzf = vimUtils.buildVimPlugin {
      name = "fzf-master";
      src = pkgs.fzf;
      buildInputs = pkgs.fzf.buildInputs;
    };
    #coc = vimUtils.buildVimPlugin rec {
    #  pname = "coc.nvim";
    #  version = "v0.0.72";
    #  name = "${pname}-${version}";
    #  src = fetchTarball "https://github.com/neoclide/coc.nvim/archive/${version}.tar.gz";
    #  buildInputs = [ pkgs.yarn pkgs.nodejs ];
    #  buildPhase = ''
    #    yarn install --frozen-lockfile --offline
    #  '';
    #};
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
    LanguageClient-neovim
    #vim-easytags
    #vim-misc
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
    #(fzf-vim.overrideAttrs (_: {
    #  src = fetchTarball https://github.com/junegunn/fzf.vim/archive/master.tar.gz;
    #}))
    gruvbox
    # custom plugins
    customPlugins.vim-sublime-monokai
    customPlugins.autocomplpop
    #customPlugins.coc
    #customPlugins.fzf
  ];

  extraConfig = ''
    " Add fzf in the path
    set rtp+=${pkgs.fzf}
  '';

  dependencies = with pkgs; [
    # Vim config dependencies
    (fzf.overrideAttrs (_: {
      src = fetchTarball https://github.com/junegunn/fzf/archive/master.tar.gz;
    }))
    rustup
    go-langserver
    llvmPackages.libclang
    cquery
    # NOT WORKING DUE TO sha256 mismatch
    #(nur.repos.mic92.nix-lsp.overrideAttrs (attr: {
    #  cargoSha256 = "13fhaspvrgymbbr230j41ppbz3a5qm12xl667cs7x888h0jvsp5g";
    #}))
    (python3.withPackages(ps: [
      ps.python-language-server
      # the following plugins are optional, they provide type checking, import sorting and code formatting
      ps.pyls-mypy ps.pyls-isort ps.pyls-black
    ]))
  ];
}
