#!/bin/bash

# Configure the common packages to download
packages=(
    sudo
    vim
    curl
    dialog
    git
    unzip
)

# Download all common packages
apt install -y "${packages[@]}"
