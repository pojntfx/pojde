#!/bin/bash

# Root script
function as_root() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Install Node
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
    apt install -y nodejs build-essential

    # Install Yarn, Jest and the IJavaScript kernel (see https://github.com/n-riesco/ijavascript#installation)
    npm install -g --unsafe-perm yarn jest ijavascript

    # Restart code-server (so that the new PATH for Jest is re-read)
    if [ "${POJDE_OPENRC}" = 'true' ]; then
        rc-service code-server restart
    else
        systemctl restart "code-server@${POJDE_USERNAME}"
    fi
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
    code-server --force --install-extension 'dbaeumer.vscode-eslint'

    # Register the IJavaScript kernel
    ijsinstall
}
