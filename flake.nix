{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { nixpkgs, home-manager, nix-darwin, ... }: {

    # Ubuntu
    homeConfigurations."codevibe@codevibe" =
      home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [
          ./hosts/ubuntu/home.nix
        ];
      };

    # NixOS
    nixosConfigurations."nixos" =
      nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [ ./hosts/nixos/system.nix ];
      };

    # macOS
    darwinConfigurations."macos" =
      nix-darwin.lib.darwinSystem {
        modules = [ ./hosts/macos/darwin.nix ];
      };
  };
}
