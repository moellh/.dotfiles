#!/bin/bash

################################################################################
# Script for installing Neovim on systems without root access
#
# - installs binary
# - installs my nvim config
################################################################################

# exit on error
set -e

# Neovim version
NEOVIM_VERSION=0.10.2

# Directory of binary
INSTALL_DIR=$HOME/.programs/nvim
mkdir -p $INSTALL_DIR

tar xvzf files/nvim-linux64.tar.gz -C $INSTALL_DIR --strip-components 1
