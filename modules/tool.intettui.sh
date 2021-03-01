#!/bin/bash

# Root script
function as_root() {
    # Install browsers and email tools from Debian repos
    apt install -y lynx links w3m git-email

    # Fetch aerc binary package
    AERC_VERSION=latest
    curl -L -o /tmp/aerc.tar.gz https://github.com/pojntfx/aerc-binaries/releases/download/${AERC_VERSION}/aerc-linux.$(uname -m).tar.gz

    # Extract the package to /
    tar -C / -xzf /tmp/aerc.tar.gz

    # Remove the extracted package
    rm /tmp/aerc.tar.gz
}

# User script
function as_user() {
    :
}
