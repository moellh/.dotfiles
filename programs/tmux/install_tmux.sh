#!/bin/bash

# Script for installing tmux on systems without have root access
#
# tmux will be installed in $HOME/.programs/tmux/bin
# assumes wget and a C/C++ compiler to be are installed

# exit on error, verbose
set -ex

TMUX_VERSION=3.5a
LIBEVENT_VERSION=2.1.12
NCURSES_VERSION=6.5

cd files

# libevent
tar -zxf libevent-${LIBEVENT_VERSION}-stable.tar.gz
cd libevent-${LIBEVENT_VERSION}-stable/
./configure --prefix=$HOME/local --enable-shared
make && make install
cd ..
rm -rf libevent-${LIBEVENT_VERSION}-stable


# ncurses
tar -zxf ncurses-${NCURSES_VERSION}.tar.gz
cd ncurses-${NCURSES_VERSION}/
./configure --prefix=$HOME/local --with-shared --with-termlib --enable-pc-files --with-pkg-config-libdir=$HOME/local/lib/pkgconfig
make && make install
cd ..
rm -rf ncurses-${NCURSES_VERSION}

# extract, configure, and compile tmux
tar -zxf tmux-${TMUX_VERSION}.tar.gz
cd tmux-${TMUX_VERSION}/
PKG_CONFIG_PATH=$HOME/local/lib/pkgconfig ./configure --prefix=$HOME/local
make && make install
cd ..
