# Nix

A home for my system configurations using Nix Flakes

Yes, I'm aware they're supposed to be in one mega-flake with imports.
For now I'm still learning and experimenting.

## Developing

### WSL

```Bash
#region Setup
NIX_DIR="$HOME/.config/nixpkgs"
mkdir -p $NIX_DIR
nix shell nixpkgs#git --command git clone https://github.com/arichtman/nix.git $NIX_DIR
cd $NIX_DIR

#region Test
sudo cp --force flake.nix configuration.nix /etc/nixos
sudo nix flake check /etc/nixos

#region Apply
sudo nixos-rebuild switch
home-manager switch

systemctl --user start auto-fix-vscode-server.service

```

## Notes

I can't locate a "good" way of ensuring that VSCode service is *started* when we switch configurations.
It's _enabled_, so it _should_ start on next boot.
I figure since we're still running imperative commands during bootstrap it'll have to do.

I tried convenience symlinking the system configuration files to our cloned repo.
In theory it would be fine for a multi-user system that practically only has one user.
That's most of my use-cases anyhow.
It looks like the context of the link is interfering with pathing and it catches it breaking hermeticity.

```Bash
sudo ln -s $(realpath flake.nix) $(realpath configuration.nix) /etc/nixos/
  error: 'flake.nix' file of flake 'path:/etc/nixos?lastModified=1672461843&narHash=sha256-lwXGTor+un0g9zRXt73NcNHW9SEkLhy1Y4l0nKTDhLM=' escapes from '/nix/store/v0siba5pd9gxqhxlnmmhha4v3dsy0gxr-source'
```

Sometimes for WSL, it won't match config on hostname for initial setup.
Run `sudo hostname bruce-banner` to temporarily adjust the host name.
It will now match and from there on Nix will manage it.

## References

- [VSCode server workaround](https://github.com/msteen/nixos-vscode-server)
- [Opinionated flake structure](https://github.com/snowfallorg/lib)
- [Home-manager configuration options](https://nix-community.github.io/home-manager/options.html)
- [Misterio77's starter configs](https://github.com/Misterio77/nix-starter-configs)

## WSL/SystemD Errors

Currently WSL build is shitting the bed.
This is just a collection of investigation and notes about it.

`rsync: [sender] change_dir "/nix/store/26mpg8igfby7zi4sfsn3s2swdrj0alcy-nixos-system-bruce-banner-23.05.20221230.293a28d/sw/share/icons" failed: No such file or directory (2)`
I can `sudo mkdir -p` and that seems to solve it, but the root cause I've not investigated. Yet.

Occasionally that ro mount issue pops up: `fchmod() of /tmp/.X11-unix failed: Read-only file system`
Run this to remove one more error: `sudo mount -o remount,rw /tmp/.X11-unix`

See "systemctl status systemd-sysctl.service" and "journalctl -xeu systemd-sysctl.service" for details.

```
Dec 31 09:13:58 bruce-banner systemd[1]: Starting Apply Kernel Variables...
Dec 31 09:13:58 bruce-banner systemd[31973]: systemd-sysctl.service: Failed to set up credentials: Protocol error
Dec 31 09:13:58 bruce-banner systemd[31973]: systemd-sysctl.service: Failed at step CREDENTIALS spawning /nix/store/9rjdvhq7hnzwwhib8na2gmllsrh671xg-systemd-252.1/lib/systemd/systemd-sysctl: Protocol error
Dec 31 09:13:58 bruce-banner systemd[1]: systemd-sysctl.service: Main process exited, code=exited, status=243/CREDENTIALS
Dec 31 09:13:58 bruce-banner systemd[1]: systemd-sysctl.service: Failed with result 'exit-code'.
Dec 31 09:13:58 bruce-banner systemd[1]: Failed to start Apply Kernel Variables.
```

See "systemctl status systemd-tmpfiles-setup-dev.service" and "journalctl -xeu systemd-tmpfiles-setup-dev.service" for details.

```
Dec 31 09:00:45 bruce-banner systemd[1]: Starting Create Static Device Nodes in /dev...
Dec 31 09:00:45 bruce-banner systemd[25331]: systemd-tmpfiles-setup-dev.service: Failed to set up credentials: Protocol error
Dec 31 09:00:45 bruce-banner systemd[25331]: systemd-tmpfiles-setup-dev.service: Failed at step CREDENTIALS spawning systemd-tmpfiles: Proto>
Dec 31 09:00:45 bruce-banner systemd[1]: systemd-tmpfiles-setup-dev.service: Main process exited, code=exited, status=243/CREDENTIALS
Dec 31 09:00:45 bruce-banner systemd[1]: systemd-tmpfiles-setup-dev.service: Failed with result 'exit-code'.
Dec 31 09:00:45 bruce-banner systemd[1]: Failed to start Create Static Device Nodes in /dev.
```

[Suggested support link](https://lists.freedesktop.org/mailman/listinfo/systemd-devel)

```
$ /nix/store/9rjdvhq7hnzwwhib8na2gmllsrh671xg-systemd-252.1/lib/systemd/systemd-sysctl
Couldn't write '16' to 'kernel/sysrq', ignoring: No such file or directory
Couldn't write '0' to 'kernel/yama/ptrace_scope', ignoring: No such file or directory
```

Sudo didn't help that command neither.
`strace`ing it, there's a heap of permission denials on stuff it's trying to write.
Those 2 errors printed above are only the missing files/dirs.
This pattern is super common, but it looks like it's failing over to read-only.

```
openat(AT_FDCWD, "/proc/sys/net/ipv6/conf/all/disable_ipv6", O_RDWR|O_NOCTTY|O_CLOEXEC) = -1 EACCES (Permission denied)
openat(AT_FDCWD, "/proc/sys/net/ipv6/conf/all/disable_ipv6", O_RDONLY|O_CLOEXEC) = 3
newfstatat(3, "", {st_mode=S_IFREG|0644, st_size=0, ...}, AT_EMPTY_PATH) = 0
read(3, "0\n", 1024)                    = 2
read(3, "", 1024)                       = 0
close(3)
```

I was able to locate some very stale kernel bugs that may be related.
Despite all this, systemd still seems to be running OK for our other services.