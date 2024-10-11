#!/bin/bash

# Script for installing tmux on systems without have root access
#
# tmux will be installed in $HOME/.programs/tmux/bin
# assumes wget and a C/C++ compiler to be are installed

# exit on error
set -e

TMUX_VERSION=3.5a
LIBEVENT_VERSION=2.1.12
NCURSES_VERSION=6.5

INSTALL_DIR="$HOME/.programs/tmux"
# download tar-file if necessary
case $TMUX_VERSION in
    3.3a)
	echo 'Use local tar-file.'
	;;
    *)
	echo 'Download requested version.'
        wget -O files/tmux-${TMUX_VERSION}.tar.gz https://github.com/tmux/tmux/releases/download/${TMUX_VERSION}/tmux-${TMUX_VERSION}.tar.gz
	;;
esac
# extract, configure, and compile dependencies
cd files
# libevent
tar xvzf libevent-${LIBEVENT_VERSION}-stable.tar.gz
cd libevent-${LIBEVENT_VERSION}-stable
./configure --prefix=${INSTALL_DIR} --disable-shared --disable-openssl 
make && make install
cd ..
# ncurses
tar xvzf ncurses-${NCURSES_VERSION}.tar.gz
cd ncurses-${NCURSES_VERSION}
./configure --prefix=${INSTALL_DIR}
make && make install
cd ..
# extract, configure, and compile tmux
tar xvzf tmux-${TMUX_VERSION}.tar.gz
cd tmux-${TMUX_VERSION}
./configure CFLAGS="-I${INSTALL_DIR}/include -I${INSTALL_DIR}/include/ncurses" LDFLAGS="-L${INSTALL_DIR}/lib -L${INSTALL_DIR}/include/ncurses -L${INSTALL_DIR}/include"
CPPFLAGS="-I${TMP_DIR}/include -I${TMP_DIR}/include/ncurses" LDFLAGS="-static -L${TMP_DIR}/include -L${TMP_DIR}/include/ncurses -L${TMP_DIR}/lib" make
cp tmux ${INSTALL_DIR}/bin
cd ..
# copy config
mkdir ${INSTALL_DIR}/.config
cp ../config/tmux.conf ${INSTALL_DIR}/.config/
echo "TMUX installation succesfull."
