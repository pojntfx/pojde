#!/bin/bash

# Root script
function as_root() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Install Node
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
    apt install -y nodejs build-essential

    # Install Yarn and the IJavaScript kernel (see https://github.com/n-riesco/ijavascript#installation)
    npm install -g --unsafe-perm ijavascript yarn
}

# User script
function as_user() {
    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the JavaScript VSCode extensions
    code-server --force --install-extension 'Orta.vscode-jest'
    code-server --force --install-extension 'kavod-io.vscode-jest-test-adapter'
    code-server --force --install-extension 'hbenl.vscode-mocha-test-adapter'
    code-server --force --install-extension 'hbenl.vscode-jasmine-test-adapter'

    # Register the IJavaScript kernel
    ijsinstall
}
