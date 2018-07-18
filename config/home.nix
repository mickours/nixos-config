with import <nixpkgs> {};
with import <nixhome> { inherit stdenv; inherit pkgs; };
let
  dotfiles_path = "/home/${user}/Projects/dotfiles/";
in
mkHome rec {
  user = "mmercier";
  files = {
	 ".tmux.conf" = "/home/${user}/Projects/dotfiles/tmux.conf";
	 ".vimrc" = "/home/${user}/Projects/dotfiles/vimrc";
	 ".bashrc".content = ''
	 echo use ZSH you moron!!
	 '';
  };
}

