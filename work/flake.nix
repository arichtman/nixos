{
  description = "Nix system configurations";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = github:nix-community/home-manager;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, home-manager, ... }@inputs :
  let
    # system = "x86_64-linux";
    # pkgs = import nixpkgs {
    #   inherit system;
    #   config = {
    #     allowUnfree = true;
    #   };
    # };
    lib = nixpkgs.lib;
    # home-manager = home-manager;
  in {
    nixosConfigurations = {
      temp-machine = lib.nixosSystem{
        system = "x86_64-linux";
        modules = [
          ./configuration.nix
        ];
      };
      main-laptop =lib.nixosSystem{
        system = "x86_64-linux";
        modules = [
          ./systems/x86_64-linux/main-laptop/default.nix
        ];
      };
    };
    # packages.${system} = {
    #   default = [ pkgs.terragrunt ];
    #   nixosConfigurations = {
    #     dev-machine = lib.nixosSystem {
    #       inherit system;
    #       modules = [
    #         # "${builtins.modulesPath}/virtualisation/amazon-image.nix"
    #         # "${modulesPath}/virtualisation/amazon-image.nix"
    #         home-manager.nixosModules.home-manager
    #       ];
    #     };
    #   };
    # };

    homeConfigurations = {
      main-laptop = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.x86_64-linux;
        modules = [ ./homes/main-laptop.nix ];
        # system = "x86_64-linux";
        # homeDirectory = "/home/nixos";
        # username = "nixos";
        # stateVersion = "22.11";
      };
    };
    # devShells.${system} = {
    #   default = pkgs.mkShell {
    #       packages = [ pkgs.terragrunt ];
    #     };
    #   imported = import ./shell.nix { inherit pkgs; };
    # };
  };
}
