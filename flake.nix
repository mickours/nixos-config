{
  description = "My personal NixOS machines configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-21.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    #simple-nixos-mailserver = {
    #  type = "git";
    #  url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver";
    #  ref = "nixos-20.09";
    #  flake = false;
    #};
    #NUR = {
    #  url = github:nix-community/NUR;
    #  flake = false;
    #};
    #my_dotfiles = {
    #  url = "github:mickours/dotfiles";
    #  flake = false;
    #};
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ... }: {
    nixosConfigurations = {
      oursbook3 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        modules = let
          nixpkgsUnfree = ({
            nixpkgs = {
              config.allowUnfree = true;
              # overlays = [ (import ./overlays/fixes.nix) ];
              inherit system;
            };
          });
        in [
          nixpkgsUnfree
          ./deployments/oursbook3.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # home-manager.users.mmercier = import ./config/home.nix;
            home-manager.users.mickours = import ./config/home.nix;
          }
          "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; rev="4c9f07277bd4bc29a051ff2a0ca58c6403e3881a"; }}/lenovo/thinkpad/x1-extreme"
        ];
      };
      #vps = nixpkgs.lib.nixosSystem {
      #  system = "x86_64-linux";

      #  modules = [
      #    ./deployments/vps.nix
      #  ];
      #};
    };
  };
}
