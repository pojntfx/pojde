#!/bin/bash

packages=(
    sudo
    vim
)

apt install -y "${packages[@]}"
