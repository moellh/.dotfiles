#!/bin/bash

################################################################################
# installs config files and default programs
################################################################################

# prints each command, exits on error
set -ex

# check current directory
DOTFILES_DIR=$(pwd)
if [[ $(basename $DOTFILES_DIR) != ".dotfiles" ]]; then
    echo "Run this script from .dotfiles directory"
    exit 1
fi

# check current shell
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
INSTALL_DIR=$HOME/local
mkdir -p $INSTALL_DIR

# STOW -------------------------------------------------------------------------

STOW_VERSION=2.4.1

cd archives
tar -xzf stow-$STOW_VERSION.tar.gz
cd stow-$STOW_VERSION

./configure --prefix=$INSTALL_DIR
make
make install

cd ..
rm -rf stow-$STOW_VERSION

cd $DOTFILES_DIR

# ------------------------------------------------------------------------------

# put config in home directory
$HOME/local/bin/stow config-stow -t ~

# TMUX -------------------------------------------------------------------------

TMUX_VERSION=3.5a
LIBEVENT_VERSION=2.1.12-stable
NCURSES_VERSION=6.5

cd archives
PKG_CONFIG_PATH=$INSTALL_DIR/lib/pkgconfig

# libevent
tar -zxf libevent-${LIBEVENT_VERSION}.tar.gz
cd libevent-${LIBEVENT_VERSION}/
./configure --prefix=$INSTALL_DIR --enable-shared
make && make install
cd ..
rm -rf libevent-${LIBEVENT_VERSION}

# ncurses
tar -zxf ncurses-${NCURSES_VERSION}.tar.gz
cd ncurses-${NCURSES_VERSION}/
./configure --prefix=$INSTALL_DIR --with-shared --with-termlib --enable-pc-files --with-pkg-config-libdir=$PKG_CONFIG_PATH
make && make install
cd ..
rm -rf ncurses-${NCURSES_VERSION}

# extract, configure, and compile tmux
tar -zxf tmux-${TMUX_VERSION}.tar.gz
cd tmux-${TMUX_VERSION}/
./configure --prefix=$INSTALL_DIR
make && make install
cd ..
rm -rf tmux-${TMUX_VERSION}

cd $DOTFILES_DIR

# ------------------------------------------------------------------------------

# Neovim -----------------------------------------------------------------------

NEOVIM_VERSION=0.10.2

tar xvzf archives/nvim-linux64.tar.gz -C $INSTALL_DIR --strip-components 1

# ------------------------------------------------------------------------------

# Git --------------------------------------------------------------------------

# puts .gitconfig into home directory
# done separately because of input of user.name and user.email
cp config/.gitconfig ~/.gitconfig
read -p "Name for .gitconfig: " git_name
git config --global user.name "$git_name"
read -p "E-Mail for .gitconfig: " git_email
git config --global user.email "$git_email"

# ------------------------------------------------------------------------------

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

# nodejs
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

nvm install 20
npm install -g tree-sitter-cli
