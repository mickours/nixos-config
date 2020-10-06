{
  description = "My personal NixOS machines configuration";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-20.09";

  outputs = { self, nixpkgs }: {
    nixosConfigurations.oursbook2 = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      modules = [
        ./deployments/oursbook2.nix
      ];
    };
  };
}
