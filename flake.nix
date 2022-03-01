{
  description = "My personal NixOS machines configuration";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-21.11";
  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-21.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };
  inputs.simple-nixos-mailserver = {
    type = "git";
    url = "https://gitlab.com/simple-nixos-mailserver/nixos-mailserver";
    ref = "nixos-21.11";
    flake = false;
  };
  #inputs.my_dotfiles = {
  #  url = "github:mickours/dotfiles";
  #  flake = false;
  #};

  outputs = { self, nixpkgs, home-manager, nixos-hardware, simple-nixos-mailserver, deploy-rs, ... }: {
    nixosConfigurations = {
      oursbook3 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";

        modules =
          let
            nixpkgsUnfree = ({
              nixpkgs = {
                config.allowUnfree = true;
                # overlays = [ (import ./overlays/fixes.nix) ];
                inherit system;
              };
            });
          in
          [
            nixpkgsUnfree
            ./deployments/oursbook3.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.mmercier = import ./config/home.nix;
              home-manager.users.mickours = import ./config/home.nix;
            }
            "${builtins.fetchGit { url = "https://github.com/NixOS/nixos-hardware.git"; rev="4c9f07277bd4bc29a051ff2a0ca58c6403e3881a"; }}/lenovo/thinkpad/x1-extreme"
          ];
      };
      vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          "${simple-nixos-mailserver}"
          ./deployments/vps.nix
        ];
      };
    };

    deploy.nodes.vps.hostname = "vps";
    deploy.nodes.vps.profiles.system = {
      user = "root";
      sshUser = "root";
      path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.vps;
    };

    # This is highly advised, and will prevent many possible mistakes
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
  };
}
