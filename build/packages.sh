#!/bin/bash

# Configure the common packages to download
packages=(
    sudo
    vim
    curl
    dialog
    systemd
    systemd-sysv
)

# Download all common packages
apt install -y "${packages[@]}"
