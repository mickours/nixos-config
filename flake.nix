{
  description = "My personal NixOS machines configuration";

  inputs.deploy-rs.url = "github:serokell/deploy-rs";
  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-24.11";
  };
  inputs.simple-nixos-mailserver = {
    url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-24.05";
  };
  inputs.my_dotfiles = {
    url = "github:mickours/dotfiles";
    flake = false;
  };
  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  inputs.pinnedZoomPkgs.url = "github:NixOS/nixpkgs/0c19708cf035f50d28eb4b2b8e7a79d4dc52f6bb";

  outputs = { self, nixpkgs, home-manager, simple-nixos-mailserver, deploy-rs, my_dotfiles, nixos-hardware, ... }@inputs: {
    nixosConfigurations = {
      oursbook3 = nixpkgs.lib.nixosSystem rec {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules =
          let
            nixpkgsUnfree = ({
              nixpkgs = {
                config.allowUnfree = true;
                inherit system;
                overlays = [ (self: super: { zoom-us = (import inputs.pinnedZoomPkgs {inherit system; config.allowUnfree = true;}).zoom-us; })  ];
                # overlays = [ (import ./overlays/fixes.nix) ];
                #config.permittedInsecurePackages = [
                #  "teams-1.5.00.23861"
                #];
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
              home-manager.extraSpecialArgs = { inherit my_dotfiles; };
              home-manager.users.mmercier = import ./config/home.nix;
              home-manager.users.mickours = import ./config/home.nix;
            }
            nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen3
          ];
      };
      vps = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };

        modules = [
          simple-nixos-mailserver.nixosModules.mailserver
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
    # Enable autoformat
    formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixpkgs-fmt;
  };
}
