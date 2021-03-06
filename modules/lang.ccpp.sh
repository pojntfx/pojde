#!/bin/bash

# Root script
function as_root() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Install clangd, cmake and gdb
    apt install -y clangd-8 cmake gdb

    # Use clangd-8 as default clangd
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-8 100

    # Download the C++ Jupyter Kernel (see https://github.com/pojntfx/xeus-cling-binaries#installation)

    # Fetch the xeus-cling binary package
    curl -L -o /tmp/xeus-cling.tar.gz https://github.com/pojntfx/xeus-cling-binaries/releases/download/latest/xeus-cling.$(uname -m).tar.gz

    # Extract the package to /usr/local/xeus-cling
    XEUS_PREFIX=/usr/local/xeus-cling
    mkdir -p ${XEUS_PREFIX}
    tar -C ${XEUS_PREFIX} -xzf /tmp/xeus-cling.tar.gz
    rm /tmp/xeus-cling.tar.gz

    # Install the kernels
    jupyter kernelspec install ${XEUS_PREFIX}/share/jupyter/kernels/xcpp11 --sys-prefix
    jupyter kernelspec install ${XEUS_PREFIX}/share/jupyter/kernels/xcpp14 --sys-prefix
    jupyter kernelspec install ${XEUS_PREFIX}/share/jupyter/kernels/xcpp17 --sys-prefix
}

# User script
function as_user() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

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
