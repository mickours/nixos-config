{ pkgs, ... }:

{
  # Bluetooth command for headsets
  systemd.user.services.mpris-proxy = {
    Unit.Description = "Mpris proxy";
    Unit.After = [ "network.target" "sound.target" ];
    Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    Install.WantedBy = [ "default.target" ];
  };
  programs = let
    my_dotfiles = builtins.fetchGit {
      url = "https://github.com/mickours/dotfiles";
      ref = "master";
      rev = "f7ee7368682e4b8b319344be009034443602e228";
    };
    my_vim_config = builtins.readFile (builtins.toPath "${my_dotfiles}/vimrc");
    my_vim_plugins = pkgs.callPackage ./my_vim_plugins.nix { };
  in {
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
    };
  };
  xdg.configFile."nvim/coc-settings.json".text =
    builtins.readFile ./coc-settings.json;
}
