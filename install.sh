#!/bin/sh


stow . -t ~


# git

cp .gitconfig ~/.gitconfig

read -p "Name for .gitconfig: " git_name
git config --global user.name "$git_name"

read -p "E-Mail for .gitconfig: " git_email
git config --global user.email "$git_email"


# zsh

mkdir -p ~/.zsh
git clone https://github.com/romkatv/powerlevel10k.git ~/.zsh/powerlevel10k
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting


# tmux

mkdir -p ~/.config/tmux/plugins
git clone https://github.com/dreamsofcode-io/catppuccin-tmux.git ~/.config/tmux/plugins/catppuccin-tmux
git clone https://github.com/tmux-plugins/tmux-sensible.git ~/.config/tmux/plugins/tmux-sensible
git clone https://github.com/tmux-plugins/tmux-yank.git ~/.config/tmux/plugins/tmux-yank
git clone https://github.com/tmux-plugins/tpm.git ~/.config/tmux/plugins/tpm
git clone https://github.com/christoomey/vim-tmux-navigator.git ~/.config/tmux/plugins/vim-tmux-navigator
