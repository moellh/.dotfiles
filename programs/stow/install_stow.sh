#!/bin/bash

################################################################################
# Install GNU Stow
################################################################################

INSTALL_DIR=$HOME/.programs/stow
mkdir -p "$INSTALL_DIR"

tar -xzf files/stow-2.4.1.tar.gz
cd stow-2.4.1 || exit 1

./configure --prefix="$INSTALL_DIR"
make
make install

# Clean um
cd ~
rm -rf stow-2.4.1

echo "export PATH="$PATH:$INSTALL_DIR/bin" >> ~/.zshrc
