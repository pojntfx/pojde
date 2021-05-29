#!/bin/bash

# Root script
function as_root() {
    # Install build dependencies
    apt install -y cmake build-essential
}

# User script
function as_user() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Install Rust
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | bash -s -- -y
    . /home/${POJDE_USERNAME}/.cargo/env

    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the Rust VSCode extension
    code-server --force --install-extension 'matklad.rust-analyzer'
    code-server --force --install-extension 'bungcip.better-toml'
    code-server --force --install-extension 'vadimcn.vscode-lldb'
    code-server --force --install-extension 'Swellaby.vscode-rust-test-adapter'

    # Download the Rust Jupyter Kernel (see https://github.com/google/evcxr/blob/master/evcxr_jupyter/README.md#linux-debianubuntu)
    rustup component add rust-src
    cargo install evcxr_jupyter
    evcxr_jupyter --install
}
