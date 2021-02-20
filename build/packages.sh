#!/bin/bash

packages=(
    sudo
    vim
    curl
)

apt install -y "${packages[@]}"
