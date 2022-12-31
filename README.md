# Nix

A home for my system configurations using Nix Flakes

Yes, I'm aware they're supposed to be in one mega-flake with imports.
For now I'm still learning and experimenting.

For WSL, it won't match config on hostname for initial setup.
Run `sudo hostname bruce-banner`.

## Developing

### WSL

```Bash
#region Setup
NIX_DIR="$HOME/.config/nixpkgs"
mkdir -p $NIX_DIR
git clone git@github.com:arichtman/nix.git $NIX_DIR
cd $NIX_DIR

#region Test
sudo cp --force flake.nix configuration.nix /etc/nixos
sudo nix flake check /etc/nixos

#region Apply
sudo nixos-rebuild switch
home-manager switch
```

## Notes

I tried convenience symlinking the system configuration files to our cloned repo.
In theory it would be fine for a multi-user system that practically only has one user.
That's most of my use-cases anyhow.
It looks like the context of the link is interfering with pathing and it catches it breaking hermeticity.

```Bash
sudo ln -s $(realpath flake.nix) $(realpath configuration.nix) /etc/nixos/
  error: 'flake.nix' file of flake 'path:/etc/nixos?lastModified=1672461843&narHash=sha256-lwXGTor+un0g9zRXt73NcNHW9SEkLhy1Y4l0nKTDhLM=' escapes from '/nix/store/v0siba5pd9gxqhxlnmmhha4v3dsy0gxr-source'
```

## References

- [VSCode server workaround](https://github.com/msteen/nixos-vscode-server)
- [Opinionated flake structure](https://github.com/snowfallorg/lib)
- [Home-manager configuration options](https://nix-community.github.io/home-manager/options.html)
- [Misterio77's starter configs](https://github.com/Misterio77/nix-starter-configs)
