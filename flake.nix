{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    agenix.url = "github:ryantm/agenix";
    agenix.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, nix-darwin, agenix, ... }: {
    # Ubuntu
    homeConfigurations."codevibe@codevibe" =
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          agenix.homeManagerModules.default
          ./hosts/ubuntu/home.nix
        ];
      };

    # NixOS
    nixosConfigurations."nixos" =
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          agenix.homeManagerModules.default
          ./hosts/nixos/system.nix
        ];
      };

    # macOS
    darwinConfigurations."macos" =
      nix-darwin.lib.darwinSystem {
        modules = [
          agenix.homeManagerModules.default
          ./hosts/macos/darwin.nix
        ];
      };
  };
}
