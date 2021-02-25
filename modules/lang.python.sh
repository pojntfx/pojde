#!/bin/bash

# Root script
function as_root() {
    :
}

# User script
function as_user() {
    # Install the Go VSCode extension
    code-server --install-extension 'ms-python.python'
}
