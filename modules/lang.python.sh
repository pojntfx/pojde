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

    # Install the Go VSCode extension
    code-server --install-extension 'ms-python.python'
}
