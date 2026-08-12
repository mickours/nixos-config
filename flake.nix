{
  description = "My personal NixOS machines configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

  inputs.home-manager = {
    url = "github:nix-community/home-manager/release-26.05";
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
      };
      # Enable autoformat
      formatter.x86_64-linux = (import nixpkgs { system = "x86_64-linux"; }).pkgs.nixfmt-tree;
    };
}
