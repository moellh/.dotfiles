# System config

Copies of the files under `/etc` (and `/boot`) that differ from the package defaults,
plus the units to enable. They are copies, not stow symlinks: root shouldn't follow links
into a home directory, and pacman may replace files in `/etc`.

```sh
system/install.sh --check   # what differs from this machine (no sudo)
system/install.sh           # show diffs, install after asking, enable missing units
```

| File | Change from the package default |
| --- | --- |
| `etc/pacman.conf` | `Color`, `ILoveCandy`, `[multilib]`, include of `arch-programs.conf` |
| `etc/pacman.d/arch-programs.conf` | own package repo |
| `etc/mkinitcpio.conf` | NVIDIA modules loaded early, `keymap` hook |
| `etc/UPower/UPower.conf` | battery levels low/critical/action 20/10/5 % (must stay descending) |
| `etc/locale.gen`, `etc/locale.conf` | English UI with German formats |
| `etc/vconsole.conf` | German console keymap |
| `etc/pam.d/login` | unlocks the GNOME keyring at login |
| `etc/fuse.conf` | `user_allow_other` |
| `etc/docker/daemon.json` | DNS servers and address pools |
| `boot/loader/entries/arch.conf.template` | kernel options (NVIDIA modeset, hibernate resume); fill in by hand |
| `services.txt` | system and user units to enable |

Not here on purpose: `fstab`, `hosts`, `hostname` and VPN/VM state are machine-specific
or private; they are in the encrypted secrets backup (`backup-secrets`).

## Updating

When you change one of these files in `/etc`, copy it back here. When pacman leaves a
`.pacnew` for one of them, merge the new default with the changes listed above, put the
result here, run `install.sh` and delete the `.pacnew`.

No NVIDIA pacman hook is needed: mkinitcpio's own hook rebuilds the initramfs when a DKMS
driver (`usr/src/*/dkms.conf`) or a prebuilt module (`usr/lib/modules/*/extramodules/`)
changes.
