#!/bin/bash

# Installs config files and default programs

# Prints each command, exits on error
set -ex

# Check current directory
DOTFILES_DIR=$(pwd)
if [[ $(basename $DOTFILES_DIR) != ".dotfiles" ]]; then
    echo "Run this script from .dotfiles directory"
    exit 1
fi

# Check current shell
read -p "Bash as current default shell (y/N): " shell
if [[ $shell == "y" ]]; then
    read -p "Already linked a .bashrc.my file? (Y/n): " linked
    if [[ $linked == "n" ]]; then
        echo 'source ~/.bashrc.my' >> $HOME/.bashrc
    fi
    [ -f "$HOME/.bashrc.my" ] || touch "$HOME/.bashrc.my"
    echo "exec zsh" >> $HOME/.bashrc.my
fi

# Create directory for installed programs
INSTALL_DIR=$HOME/local
mkdir -p $INSTALL_DIR

# Install Stow =================================================================

read -p "Install GNU Stow? (y/N): " install_stow
if [[ $install_stow == "y" ]]; then
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

    # Put config in home directory with local stow installation
    read -p "Stow config files? (y/N): " stow_config
    if [[ $stow_config == "y" ]]; then
        $HOME/local/bin/stow config -t ~
    fi
else
    # Put config in home directory with system stow installation
    read -p "Stow config files? (y/N): " stow_config
    if [[ $stow_config == "y" ]]; then
        stow --adopt config -t ~
    fi
fi

# Install Tmux with dependencies ===============================================

read -p "Install Tmux? (y/N): " install_tmux
if [[ $install_tmux == "y" ]]; then
    TMUX_VERSION=3.5a
    LIBEVENT_VERSION=2.1.12-stable
    NCURSES_VERSION=6.5

    cd archives
    PKG_CONFIG_PATH=$INSTALL_DIR/lib/pkgconfig

    # Libevent
    tar -zxf libevent-${LIBEVENT_VERSION}.tar.gz
    cd libevent-${LIBEVENT_VERSION}/
    ./configure --prefix=$INSTALL_DIR --enable-shared
    make && make install
    cd ..
    rm -rf libevent-${LIBEVENT_VERSION}

    # Ncurses
    tar -zxf ncurses-${NCURSES_VERSION}.tar.gz
    cd ncurses-${NCURSES_VERSION}/
    ./configure --prefix=$INSTALL_DIR --with-shared --with-termlib --enable-pc-files --with-pkg-config-libdir=$PKG_CONFIG_PATH
    make && make install
    cd ..
    rm -rf ncurses-${NCURSES_VERSION}

    # Extract, configure, and compile Tmux
    tar -zxf tmux-${TMUX_VERSION}.tar.gz
    cd tmux-${TMUX_VERSION}/
    ./configure --prefix=$INSTALL_DIR
    make && make install
    cd ..
    rm -rf tmux-${TMUX_VERSION}

    cd $DOTFILES_DIR
fi


# Install Neovim ===============================================================

read -p "Install Neovim? (y/N): " install_nvim
if [[ $install_nvim == "y" ]]; then
    tar xvzf archives/nvim-linux64.tar.gz -C $INSTALL_DIR --strip-components 1
fi


# Install Zsh plugins ==========================================================

read -p "Install Zsh plugins? (y/N): " install_zsh_plugins
if [[ $install_zsh_plugins == "y" ]]; then
    mkdir -p ~/.zsh
    git clone https://github.com/romkatv/powerlevel10k.git ~/.zsh/powerlevel10k
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.zsh/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.zsh/zsh-syntax-highlighting
fi


# Install Tmux plugin manager ==================================================

read -p "Install Tmux plugin manager? (y/N): " install_tpm
if [[ $install_tpm == "y" ]]; then
    mkdir -p ~/.config/tmux/plugins
    git clone https://github.com/tmux-plugins/tpm.git ~/.config/tmux/plugins/tpm
fi


# Install Nodejs with Tree-sitter ==============================================

read -p "Install Nodejs? (y/N): " install_node
if [[ $install_node == "y" ]]; then
    curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash
    nvm install 22
    npm install -g tree-sitter-cli
fi
