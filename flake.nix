{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = { nixpkgs, home-manager, nix-darwin, nix-flatpak, ... }@inputs: {
    # Ubuntu
    homeConfigurations."codevibe@codevibe" =
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          nix-flatpak.homeManagerModules.nix-flatpak
          ./hosts/ubuntu/home.nix
        ];
      };

    # NixOS
    nixosConfigurations."nixos" =
      nixpkgs.lib.nixosSystem {
        specialArgs = { inherit inputs; };
        modules = [
          nix-flatpak.nixosModules.nix-flatpak
          ./hosts/nixos/system.nix
        ];
      };

    # macOS
    darwinConfigurations."macos" =
      nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs; };
        modules = [
          ./hosts/macos/darwin.nix
        ];
      };
  };
}
