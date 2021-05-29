#!/bin/bash

# Root script
function as_root() {
    # Install shellcheck
    apt install -y shellcheck
}

# User script
function as_user() {
    # Read versions
    . /opt/pojde/versions.sh

    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the Bash VSCode extensions
    VERSION="${SHELL_FORMAT_EXTENSION_VERSION}"
    FILE=/tmp/shell-format.vsix
    curl -L -o ${FILE} https://github.com/foxundermoon/vs-shell-format/releases/download/v${VERSION}/shell-format-${VERSION}.vsix
    code-server --force --install-extension ${FILE}
    rm ${FILE}

    code-server --force --install-extension 'Remisa.shellman'
    code-server --force --install-extension 'timonwong.shellcheck'
    code-server --force --install-extension 'rogalmic.bash-debug'

    # Download the Bash Jupyter Kernel (see https://github.com/takluyver/bash_kernel)
    pip3 install bash_kernel
    python3 -m bash_kernel.install
}
