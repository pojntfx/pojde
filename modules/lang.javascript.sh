#!/bin/bash

# Root script
function as_root() {
    # Read configuration file
    . /opt/pojde-ng/preferences/preferences.sh

    # Install Node
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
    apt install -y nodejs build-essential

    # Install Yarn and the IJavaScript kernel (see https://github.com/n-riesco/ijavascript#installation)
    npm install -g --unsafe-perm ijavascript yarn
}

# User script
function as_user() {
    # Register the IJavaScript kernel
    ijsinstall
}
