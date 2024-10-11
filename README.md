# Dotfiles

This repo contains my config files which I would like to backup and eventually
install on a new machine.  In addition, it installs GNU Stow, TMUX, Neovim
without root access.  The script assumes that zsh, bash, git, wget, a C/C++
compiler is already installed.

For installation, just run `install.sh` in the `.dotfiles` directory.  This will
also use zsh as the default shell.  So source the `rc` file of the currently
set shell to apply the changes to the current session.

`packages.txt` contains a list of packages that are currently installed on my
system using the `yay` package manager on Arch Linux. I'm planning to add a
script which installs these (or at least its relevant) packages.

## Configs

- Neovim in `.config/nvim`
- Tmux in `.config/tmux`
- Kitty in `.config/kitty`

- Zsh in `.zshrc`
- gitconfig in `.gitconfig`
- Dircolors in `.dircolors`
- PowerLevel10k in `.p10k.zsh`

## Custom Scripts

- todo
