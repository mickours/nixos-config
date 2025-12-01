{
  description = "My personal NixOS machines configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

  inputs.deploy-rs = {
    url = "github:serokell/deploy-rs";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.simple-nixos-mailserver = {
    url = "gitlab:simple-nixos-mailserver/nixos-mailserver/nixos-25.11";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.my_dotfiles = {
    url = "github:mickours/dotfiles";
    flake = false;
  };

  inputs.adrien_config = {
    url = "github:adfaure/nix_configuration/master";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  inputs.nixos-hardware.url = "github:NixOS/nixos-hardware/master";

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      simple-nixos-mailserver,
      deploy-rs,
      my_dotfiles,
      nixos-hardware,
      adrien_config,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      adrienPkgs = adrien_config.packages."${system}";
    in
    {
      nixosConfigurations = {
        oursbook3 = nixpkgs.lib.nixosSystem rec {
          specialArgs = { inherit inputs adrienPkgs; };
          modules =
            let
              nixpkgsUnfree = ({
                nixpkgs = {
                  config.allowUnfree = true;
                  inherit system;
                  # overlays = [ (self: super: { zoom-us = (import inputs.pinnedZoomPkgs {inherit system; config.allowUnfree = true;}).zoom-us; })  ];
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
                home-manager.extraSpecialArgs = { inherit my_dotfiles adrienPkgs; };
                home-manager.users.mmercier = import ./config/home.nix;
                home-manager.users.mickours = import ./config/home.nix;
              }
              nixos-hardware.nixosModules.lenovo-thinkpad-x1-extreme-gen3
            ];
        };
        vps = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { inherit inputs adrienPkgs; };

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
