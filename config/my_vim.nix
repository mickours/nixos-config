{vim_configurable, vimPlugins, vimUtils, my_vim_config}:

let
  customPlugins = {
    completor = vimUtils.buildVimPlugin {
      name = "completor-git-2018-11-06";
      buildPhase = "true"; # building requires npm (for js) so I disabled it
      src = fetchGit {
        url = "https://github.com/maralla/completor.vim.git";
        rev = "9d1b13e8da098aeb561295ad6cf5c3c2f04e2183";
        ref = "master";
      };
      meta.homepage = https://github.com/maralla/completor.vim;
    };
  };
  in
  vim_configurable.customize {
    name = "v";

    # add imy custom .vimrc
    vimrcConfig.customRC = my_vim_config + ''
      let g:LanguageClient_serverCommands = {
        \ 'python': ['pyls']
        \ }
       nnoremap <F5> :call LanguageClient_contextMenu()<CR>
       nnoremap <silent> gh :call LanguageClient_textDocument_hover()<CR>
       nnoremap <silent> gd :call LanguageClient_textDocument_definition()<CR>
       nnoremap <silent> gr :call LanguageClient_textDocument_references()<CR>
       nnoremap <silent> gs :call LanguageClient_textDocument_documentSymbol()<CR>
       nnoremap <silent> <F2> :call LanguageClient_textDocument_rename()<CR>
       nnoremap <silent> gf :call LanguageClient_textDocument_formatting()<CR>
    '';

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
        ];
      # manually loadable by calling `:packadd $plugin-name`
      opt = [  ];
      # To automatically load a plugin when opening a filetype, add vimrc lines like:
      # autocmd FileType php :packadd phpCompletion
    };
 }
