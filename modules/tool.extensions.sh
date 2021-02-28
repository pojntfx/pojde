#!/bin/bash

# Root script
function as_root() {
    :
}

# User script
function as_user() {
    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the common VSCode extensions
    code-server --force --install-extension 'esbenp.prettier-vscode'
    code-server --force --install-extension 'eamodio.gitlens'
    code-server --force --install-extension 'mhutchie.git-graph'
    code-server --force --install-extension 'hbenl.vscode-test-explorer'
}
