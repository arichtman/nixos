{ modulesPath, ... }:
let
  nixos-wsl = import ./nixos-wsl;
in
{
  imports = [
    "${modulesPath}/profiles/minimal.nix"
    nixos-wsl.nixosModules.wsl
  ];
}