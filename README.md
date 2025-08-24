# Dotfiles

This repo contains my config files which I would like to backup and eventually install on a new machine.  In addition,
it installs GNU Stow, TMUX, Neovim without root access.  The script assumes that zsh, bash, git, wget, a C/C++ compiler
is already installed.

For installation, just run `install.sh` in the `.dotfiles` directory.  This will also use zsh as the default shell.  So
source the `rc` file of the currently set shell to apply the changes to the current session.

`packages.txt` contains a list of packages that are currently installed on my system using the `yay` package manager on
Arch Linux. I'm planning to add a script which installs these (or at least its relevant) packages.

- [ ] Update `install.sh` in some meaningful way, maybe just add README.md to each config, or split the script into
      multiple scripts

## Configs

- Neovim in `.config/nvim`
- Tmux in `.config/tmux`
- Kitty in `.config/kitty`

- Zsh in `.zshrc`
- gitconfig in `.gitconfig`
- Dircolors in `.dircolors`
- PowerLevel10k in `.p10k.zsh`

- [ ] Add missing configs

## Custom Scripts

- [ ] Update to `#!/usr/bin/env bash` instead of `#!/bin/bash`, so it works on e.g. Nixos
- [ ] Replace comments as documentation with `HELP_MESSAGE` text that is automatically shown with option `-h`, `--help`,
      or on error caused by the user, e.g. bad arguments

## Google Drive with RClone Bisync

1. Ensure that `rclone` is installed
2. See `rclone.conf` file in my Google Drive and copy it manually to `~/.config/rclone/rclone.conf`
3. Execute `mkdir ~/drive` and `touch .RCLONE_TEST` to create the local directory and test file
4. Execute `cloudsync --resync` (see `config/.scipts/cloudsync` for the rclone options it uses)

This downloads all files in my Google Drive to the `~/drive/` directory. The `update` script automatically calls
`cloudsync` to ensure that the folders is up to date. To update it manually, simply execute `cloudsync`. On errors, it
may be necessary to run the command with `--resync` or `--force` depending on the given error.
