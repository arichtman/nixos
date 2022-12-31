# nixos

home for my nixos system configurations

Yes, I'm aware they're supposed to be in one mega-flake with imports.
For now I'm still learning and experimenting.

Won't match config on hostname for initial setup `sudo hostname bruce-banner`

## Developing

`sudo cp -f flake.nix configuration.nix home.nix /etc/nixos && sudo nix flake check /etc/nixos`

## References

- [VSCode server workaround](https://github.com/msteen/nixos-vscode-server)
- [Opinionated flake structure](https://github.com/snowfallorg/lib)
