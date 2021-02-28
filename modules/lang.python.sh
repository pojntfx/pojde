#!/bin/bash

# Root script
function as_root() {
    # Set pip3 as default pip (Python 2 is EOL)
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1
}

# User script
function as_user() {
    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the Python VSCode extension
    code-server --force --install-extension 'ms-python.python'
}
