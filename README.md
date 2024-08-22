# Dotfiles

This repo contains my config files which I would like to backup and eventually
install on a new machine.

In addition, it has a script `install.sh` which installs the config files in
the correct locations with its dependencies.  It primarily utilizes GNU Stow to
create symlinks to the files in the repo.

`packages.txt` contains a list of packages that are currently installed on my
system using the `yay` package manager on Arch Linux. I'm planning to add a
script which installs these (or at least its relevant) packages.

## Current configs

- Neovim in `.config/nvim`
- Tmux in `.config/tmux`
- Kitty in `.config/kitty`

- Zsh in `.zshrc`
- gitconfig in `.gitconfig`
- Dircolors in `.dircolors`
- PowerLevel10k in `.p10k.zsh`
