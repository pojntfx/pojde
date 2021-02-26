#!/bin/bash

# Root script
function as_root() {
    # Read configuration file
    . /opt/pojde-ng/preferences/preferences.sh

    # Install clangd, cmake and gdb
    apt install -y clangd-8 cmake gdb

    # Use clangd-8 as default clangd
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-8 100
}

# User script
function as_user() {
    # Read configuration file
    . /opt/pojde-ng/preferences/preferences.sh

    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the C/C++ VSCode extension
    code-server --force --install-extension 'llvm-vs-code-extensions.vscode-clangd'
    code-server --force --install-extension 'webfreak.debug'
    code-server --force --install-extension 'twxs.cmake'
    code-server --force --install-extension 'ms-vscode.cmake-tools'

    # Install cmake-format VSCode extension
    VSIX_VERSION=0.6.13
    VSIX_FILE=/tmp/cmake-format.vsix
    curl -L -o ${VSIX_FILE} https://github.com/cheshirekow/cmake_format/releases/download/v${VSIX_VERSION}/cmake-format-${VSIX_VERSION}.vsix
    code-server --force --install-extension ${VSIX_FILE}
    rm ${VSIX_FILE}
}
