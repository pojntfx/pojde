#!/bin/bash

# Root script
function as_root() {
    # Install build dependencies
    apt install -y cmake build-essential
}

# User script
function as_user() {
    # Read configuration file
    . /opt/pojde-ng/preferences/preferences.sh

    # Install Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    . /home/${POJDE_NG_USERNAME}/.cargo/env

    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the Rust VSCode extension
    code-server --install-extension 'matklad.rust-analyzer'
    code-server --install-extension 'bungcip.better-toml'
    code-server --install-extension 'vadimcn.vscode-lldb'

    # Download the Go Jupyter Kernel (see https://github.com/google/evcxr/blob/master/evcxr_jupyter/README.md#linux-debianubuntu)
    rustup component add rust-src
    cargo install evcxr_jupyter
    evcxr_jupyter --install
}
