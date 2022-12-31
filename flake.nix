{
  description = "Ariel's machine configs";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Either pin both H-M and NixPkgs to a version or use master+unstable
    # nixpkgs.url = "nixpkgs/nixos-22.05";
    # home-manager.url = "github:nix-community/home-manager/release-22.05";
    # home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/nixos-wsl/22.05-5c211b47";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };
  # TODO: What's this inputs thing anyways?
  outputs = { self, nixpkgs, home-manager, nixos-wsl, ... }@inputs :
  let

  in {
    nixosConfigurations = {
      bruce-banner = nixpkgs.lib.nixosSystem{
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];
      };
    };
    homeConfigurations."nixos@bruce-banner" = home-manager.lib.homeManagerConfiguration {
      # TODO: Should this be legacy packages?
      pkgs = nixpkgs.legacyPackages.x86_64-linux;
      modules = [ ./home.nix ];
    };
  };
}