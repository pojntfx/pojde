#!/bin/bash

# Root script
function as_root() {
    # Read configuration file
    . /opt/pojde-ng/preferences/preferences.sh

    # Install clangd, cmake and gdb
    apt install -y clangd-8 cmake gdb

    # Use clangd-8 as default clangd
    update-alternatives --install /usr/bin/clangd clangd /usr/bin/clangd-8 100

    # Download the C++ Jupyter Kernel (see https://github.com/jupyter-xeus/xeus-cling#installation-from-source)

    # Install miniforge
    MINIFORGE_PREFIX=/usr/local/miniforge
    if [ "$(uname -m)" = 'x86_64' ]; then
        curl -L -o /tmp/miniforge.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-x86_64.sh
    else
        curl -L -o /tmp/miniforge.sh https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-Linux-aarch64.sh
    fi
    chmod +x /tmp/miniforge.sh
    mkdir -p ${MINIFORGE_PREFIX}
    /tmp/miniforge.sh -bfp /usr/local/miniforge -u
    rm /tmp/miniforge.sh

    # Add miniforge to the path temporarily
    export PATH="$PATH:${MINIFORGE_PREFIX}/bin"

    # Install dependencies
    conda install -c conda-forge -y cmake xeus=1.0.0 cling=0.8 clangdev=5.0 llvmdev=5 nlohmann_json cppzmq xtl pugixml cxxopts

    # Install xeus-cling
    XEUS_CLING_VERSION=0.12.0
    rm -rf /tmp/xeus-cling
    cd /tmp
    git clone https://github.com/jupyter-xeus/xeus-cling.git
    cd xeus-cling
    git checkout ${XEUS_CLING_VERSION}
    mkdir -p build && cd build
    cmake -D CMAKE_INSTALL_PREFIX=${MINIFORGE_PREFIX} -D CMAKE_INSTALL_LIBDIR=${MINIFORGE_PREFIX}/lib -D DOWNLOAD_GTEST=ON ..
    make install -j$(nproc)

    # Register kernel with Jupyter
    jupyter kernelspec install ${MINIFORGE_PREFIX}/share/jupyter/kernels/xcpp11/ --sys-prefix
    jupyter kernelspec install ${MINIFORGE_PREFIX}/share/jupyter/kernels/xcpp14/ --sys-prefix
    jupyter kernelspec install ${MINIFORGE_PREFIX}/share/jupyter/kernels/xcpp17/ --sys-prefix

    # Clean up
    rm -rf /tmp/xeus-cling
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
