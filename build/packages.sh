#!/bin/bash

# Configure the common packages to download
packages=(
    sudo
    vim
    curl
)

# Download all common packages
apt install -y "${packages[@]}"
