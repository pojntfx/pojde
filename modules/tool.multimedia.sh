#!/bin/bash

# Root script
function as_root() {
    # Install Node (webtorrent-hybrid and spotify-dl depend on it)
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
    apt install -y nodejs

    # Install multimedia tools available from Debian repos
    apt install -y ffmpeg imagemagick handbrake handbrake-cli

    # Install multimedia tools available from pip
    pip3 install youtube_dl

    # Install multimedia tools available from NPM
    npm i -g --unsafe-perm webtorrent-hybrid spotify-dl
}

# User script
function as_user() {
    :
}
