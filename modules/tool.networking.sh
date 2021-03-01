#!/bin/bash

# Root script
function as_root() {
    # Install Node (serve and localtunnel depend on it)
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
    apt install -y nodejs

    # Install networking tools available from Debian repos
    apt install -y iproute2 wireshark tshark iftop iotop nmap iperf3

    # Install networking tools available from pip
    pip3 install speedtest-cli

    # Install networking tools available from NPM
    npm i -g serve localtunnel
}

# User script
function as_user() {
    :
}
