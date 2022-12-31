{ lib, pkgs, config, modulesPath, ... }:

with lib;
let
  nixos-wsl = import ./nixos-wsl;
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    nixos-wsl.nixosModules.wsl
    (fetchTarball {
      url = "https://github.com/msteen/nixos-vscode-server/tarball/master";
      sha256 = "1qga1cmpavyw90xap5kfz8i6yz85b0blkkwvl00sbaxqcgib2rvv";
    })
    #home-manager
  ];

  wsl = {
    enable = true;
    automountPath = "/mnt";
    defaultUser = "nixos";
    startMenuLaunchers = true;

    # Enable native Docker support
    docker-native.enable = true;

    # Enable integration with Docker Desktop (needs to be installed)
    # docker-desktop.enable = true;

  };
  virtualisation.docker = {
    autoPrune.enable = true;
    enable = true;
    rootless.enable = true;
    rootless.setSocketVariable = true;
  };
  # Enable nix flakes
  nix.package = pkgs.nixFlakes;
  # Set system packages
  environment.systemPackages = with pkgs; [
    wget
  ];
  users.users.nixos = {
    extraGroups = [ "docker" ];
    isNormalUser = true;
  };
  # Enable the OpenSSH server
  # services.sshd.enable = true;

  # Enable VSCode server service
  services.vscode-server.enable = true;
  # Enable unfree packages (for vscode)
  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = ''
    experimental-features = nix-command flakes
  '';

  system.stateVersion = "22.11";
}
