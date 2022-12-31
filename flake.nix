{
  description = "Ariel's machine configs";
  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";

    home-manger.url = "github:nix-community/home-manager/release-22.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-wsl.url = "github:nix-community/nixos-wsl/22.05-5c211b47";
    nixos-wsl.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nixpkgs, home-manager, nixos-wsl, ... }@inputs :
  let
    
    # pkgs = import nixpkgs {
    #   inherit system;
    #   config = {
    #     allowUnfree = true;
    #   };
    # };
    # lib = nixpkgs.lib;
    # home-manager = home-manager;
  in {
    # homeManagerConfigurations = {
    #   bruce-banner = home-manager.lib.homeManagerConfigurations {
    #     inherit system pkgs;
    #     username = "nixos";
    #     homeDirectory = "/home/nixos";
    #     configuration = {
    #       imports = [];
    #     };
    #   };
    # };
    nixosConfigurations = {
      bruce-banner = nixpkgs.lib.nixosSystem{
        system = "x86_64-linux";
        modules = [
          # ./bruce-banner.nix
          ./configuration.nix
          # home-manager.homeConfiguration = {
          #   useGlobalPkgs = true;
          #   useUserPackages = true;
          #   users.nixos = { imports = [ ./home.nix ]; };
          # }
        ];
      };
    };
  };
}