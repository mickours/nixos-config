{vim_configurable, vimPlugins, vimUtils, my_vim_config}:

let
  customPlugins = {
    completor = vimUtils.buildVimPlugin {
      name = "completor-git-2019-03-14";
      buildPhase = "true"; # building requires npm (for js) so I disabled it
      src = fetchGit {
        url = "https://github.com/maralla/completor.vim.git";
        rev = "0b5b7992408ee6077ea923402d5eb3982b7af6ce";
        ref = "master";
      };
      meta.homepage = https://github.com/maralla/completor.vim;
    };
  };
  in
  vim_configurable.customize {
    name = "v";

    ## add imy custom .vimrc
    #vimrcConfig.customRC = my_vim_config + ''
    #'';

    # store your plugins in Vim packages
    vimrcConfig.packages.myVimPackage = with vimPlugins; {
      # loaded on launch
      start = [
          #youcompleteme
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
          customPlugins.completor
          fzf-vim
        ];
      # manually loadable by calling `:packadd $plugin-name`
      opt = [  ];
      # To automatically load a plugin when opening a filetype, add vimrc lines like:
      # autocmd FileType php :packadd phpCompletion
    };
 }
