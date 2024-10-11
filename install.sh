#!/bin/bash

# exits on error
set -e
# print each command
set -x

DOTFILES_DIR=$(pwd)
if [[ basename $DOTFILES_DIR != ".dotfiles" ]]; then
    echo "Run this script from .dotfiles directory"
    exit 1
fi

read -p "Bash as current default shell (y/N): " shell

if [[ $shell == "y" ]]; then
    read -p "Already linked a .bashrc.my file? (Y/n): " linked
    if [[ $linked == "n" ]]; then
        echo 'source ~/.bashrc.my' >> $HOME/.bashrc
    fi
    [ -f "$HOME/.bashrc.my" ] || touch "$HOME/.bashrc.my"
    echo "exec zsh" >> $HOME/.bashrc.my
fi

# Directory for installed programs
mkdir -p $HOME/.programs

# install STOW
cd $DOTFILES_DIR/programs/stow
./install_stow.sh
cd $DOTFILES_DIR

# put config in home directory
stow . -t ~

# TMUX
mkdir -p $HOME/.programs/tmux
cd $DOTFILES_DIR/programs/tmux
./install_tmux.sh
cd $DOTFILES_DIR

# Neovim
mkdir -p $HOME/.programs/nvim
cd ${DOTFILES_DIR}/programs/nvim
./install_nvim.sh
cd $DOTFILES_DIR

# puts .gitconfig into home directory
# done separately because of input of user.name and user.email
cp .gitconfig ~/.gitconfig
read -p "Name for .gitconfig: " git_name
git config --global user.name "$git_name"
read -p "E-Mail for .gitconfig: " git_email
git config --global user.email "$git_email"

# installs zsh plugins
mkdir -p ~/.zsh
git clone https://github.com/romkatv/powerlevel10k.git ~/.zsh/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting

# installs tmux plugins
mkdir -p ~/.config/tmux/plugins
git clone https://github.com/dreamsofcode-io/catppuccin-tmux.git ~/.config/tmux/plugins/catppuccin-tmux
git clone https://github.com/tmux-plugins/tmux-sensible.git ~/.config/tmux/plugins/tmux-sensible
git clone https://github.com/tmux-plugins/tmux-yank.git ~/.config/tmux/plugins/tmux-yank
git clone https://github.com/tmux-plugins/tpm.git ~/.config/tmux/plugins/tpm
git clone https://github.com/christoomey/vim-tmux-navigator.git ~/.config/tmux/plugins/vim-tmux-navigator
