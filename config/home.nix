{ pkgs, my_dotfiles, ... }:
let
  my_tmux_config = builtins.readFile (builtins.toPath "${my_dotfiles}/tmux.conf");
  my_zsh_config = builtins.readFile (builtins.toPath "${my_dotfiles}/zshrc.local");
  my_zellij_config = builtins.readFile (builtins.toPath "${my_dotfiles}/config/zellij/config.kdl");
in
{
  home.stateVersion = "25.11";
  home.packages = with pkgs; [
    zsh-powerlevel10k
    meslo-lgs-nf
  ];

  # Bluetooth command for headsets
  systemd.user.services.mpris-proxy = {
    Unit.Description = "Mpris proxy";
    Unit.After = [
      "network.target"
      "sound.target"
    ];
    Service.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
    Install.WantedBy = [ "default.target" ];
  };
  programs = {
    helix = {
      enable = true;
      extraPackages = with pkgs; [
        nil
        ruff
      ];
      settings = {
        theme = "autumn_night_transparent";
        editor.cursor-shape = {
          normal = "block";
          insert = "bar";
          select = "underline";
        };
        keys.normal = {
          # Muscle memory
          "$" = "goto_line_end";
          "^" = "goto_first_nonwhitespace";
          # Escape the madness! No more fighting with the cursor! Or with multiple cursors!
          esc = [
            "collapse_selection"
            "keep_primary_selection"
          ];

          # Search for word under cursor
          "*" = [
            "move_char_right"
            "move_prev_word_start"
            "move_next_word_end"
            "search_selection"
            "search_next"
          ];
          "#" = [
            "move_char_right"
            "move_prev_word_start"
            "move_next_word_end"
            "search_selection"
            "search_prev"
          ];

        };
        keys.insert = {
          # Escape the madness! No more fighting with the cursor! Or with multiple cursors!
          esc = [
            "collapse_selection"
            "normal_mode"
          ];
        };
        keys.select = {
          # Muscle memory
          "$" = "goto_line_end";
          "^" = "goto_first_nonwhitespace";
          G = "goto_file_end";
          "%" = "match_brackets";

          # Clipboards over registers ye ye
          d = [
            "yank_main_selection_to_clipboard"
            "delete_selection"
          ];
          x = [
            "yank_main_selection_to_clipboard"
            "delete_selection"
          ];
          y = [
            "yank_main_selection_to_clipboard"
            "normal_mode"
            "flip_selections"
            "collapse_selection"
          ];
          p = "replace_selections_with_clipboard"; # No life without this
          P = "paste_clipboard_before";

          # Escape the madness! No more fighting with the cursor! Or with multiple cursors!
          esc = [
            "collapse_selection"
            "keep_primary_selection"
            "normal_mode"
          ];
        };
      };
      languages.language-server.typescript-language-server = with pkgs.nodePackages; {
        command = "${typescript-language-server}/bin/typescript-language-server";
        args = [
          "--stdio"
          "--tsserver-path=${typescript}/lib/node_modules/typescript/lib"
        ];
      };
      languages.language-server.nil = {
        command = "${pkgs.nil}/bin/nil";
        config = {
          rootPatterns = [ "flake.nix" ];
        };
      };
      languages.language = [
        {
          name = "nix";
          auto-format = true;
          formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
          file-types = [ "nix" ];
        }
        {
          name = "python";
          auto-format = true;
        }
      ];
      themes = {
        autumn_night_transparent = {
          "inherits" = "autumn_night";
          "ui.background" = { };
        };
      };
    };
    tmux.enable = true;
    tmux.extraConfig = my_tmux_config;
    zsh.enable = true;
    zsh.initContent = (builtins.readFile ./zshrc) + my_zsh_config;
    git = {
      enable = true;
      settings.user.name = "Michael Mercier";
    };
    # Modern teminal tools
    fzf.enable = true;
    fzf.enableZshIntegration = true;
    zellij.enable = true;
    lf.enable = true;
    eza.enable = true;
    lazygit.enable = true;
    ripgrep.enable = true;
  };
  # Zsh extra config
  home.file.".p10k.zsh".text = builtins.readFile ./p10k.zsh;
  # Zellij config
  home.file.".config/zellij/config.kdl".text = my_zellij_config;

  # Fix browserpass
  home.file.".mozilla/native-messaging-hosts/com.github.browserpass.native.json".source =
    "${pkgs.browserpass}/lib/mozilla/native-messaging-hosts/com.github.browserpass.native.json";
  home.file.".mozilla/native-messaging-hosts/org.gnome.chrome_gnome_shell.json".source =
    "${pkgs.gnome-browser-connector}/lib/mozilla/native-messaging-hosts/org.gnome.chrome_gnome_shell.json";

  services.syncthing.enable = true;
}
