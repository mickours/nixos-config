{ config, lib, pkgs, ... }:
let
  pkgs_lists = import ../config/my_pkgs_list.nix { inherit pkgs; };
  cfg = config.environment.mickours.development;
in
with lib; {
  options.environments.mickours.development = {
    enable = mkEnableOption "development";
  };

  config = mkIf config.environments.mickours.development.enable {
    environment.systemPackages = pkgs_lists.development;

    # make sure dependencies are well defined
    nix.settings.sandbox = true;

    # allow my user to build
    nix.settings.trusted-users = [ "root" "mmercier" ];

    # Use all cores
    nix.settings.cores = 0;

    # keep build dpendencies to enable offline rebuild
    nix.extraOptions = ''
      gc-keep-outputs = true
      gc-keep-derivations = true
    '';

    # Add Batsim cachix to my nix cache
    nix.settings.substituters = [ "https://cache.nixos.org/" "https://batsim.cachix.org" ];
    nix.settings.trusted-public-keys =
      [ "batsim.cachix.org-1:IQ/4c8P/yzhxQwp6t58LatLcvHz0qMolEHJQz9w9pxc=" ];
    nixpkgs.config.allowUnfree = true;
    nixpkgs.config.packageOverrides = pkgs: {
      nur = import
        (builtins.fetchTarball
          "https://github.com/nix-community/NUR/archive/master.tar.gz")
        {
          inherit pkgs;
        };
    };

    # Enable CCache to avoid recompiling everyhing everytime
    programs.ccache.enable = true;
    nix.settings.extra-sandbox-paths = [ config.programs.ccache.cacheDir ];
    nixpkgs.overlays = [
      (self: super: {
        ccacheWrapper = super.ccacheWrapper.override {
          extraConfig = ''
            export CCACHE_COMPRESS=1
            export CCACHE_DIR="${config.programs.ccache.cacheDir}"
            export CCACHE_UMASK=007
            if [ ! -d "$CCACHE_DIR" ]; then
              echo "====="
              echo "Directory '$CCACHE_DIR' does not exist"
              echo "Please create it with:"
              echo "  sudo mkdir -m0770 '$CCACHE_DIR'"
              echo "  sudo chown root:nixbld '$CCACHE_DIR'"
              echo "====="
              exit 1
            fi
            if [ ! -w "$CCACHE_DIR" ]; then
              echo "====="
              echo "Directory '$CCACHE_DIR' is not accessible for user $(whoami)"
              echo "Please verify its access permissions"
              echo "====="
              exit 1
            fi
          '';
        };
      })
    ];
  };
}
