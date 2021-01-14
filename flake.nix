{
  description = "My personal NixOS machines configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";
    #home-manager = {
    #  url = "github:rycee/home-manager/master";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
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
    #  url = github:mickours/dotfiles;
    #  flake = false;
    #};
  };

  outputs = { self, nixpkgs, ... }: {
    nixosConfigurations = {
      oursbook2 = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          ({
            nixpkgs = {
              config.allowUnfree =
                true; # this is the only allowUnfree that's actually doing anything
            };
          })
          ./deployments/oursbook2.nix
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
