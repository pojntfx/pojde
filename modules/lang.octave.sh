#!/bin/bash

# Root script
function as_root() {
    # Install Octave
    apt install -y octave gnuplot
}

# User script
function as_user() {
    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the Octave VSCode extensions
    VSIX_VERSION=0.2.12
    VSIX_FILE=/tmp/octave-hacking.vsix
    curl --compressed -L -o ${VSIX_FILE} https://marketplace.visualstudio.com/_apis/public/gallery/publishers/apjanke/vsextensions/octave-hacking/${VSIX_VERSION}/vspackage
    code-server --force --install-extension ${VSIX_FILE}
    rm ${VSIX_FILE}

    VSIX_VERSION=0.0.3
    VSIX_FILE=/tmp/octave.vsix
    curl --compressed -L -o ${VSIX_FILE} https://marketplace.visualstudio.com/_apis/public/gallery/publishers/toasty-technologies/vsextensions/octave/${VSIX_VERSION}/vspackage
    code-server --force --install-extension ${VSIX_FILE}
    rm ${VSIX_FILE}

    VSIX_VERSION=0.4.9
    VSIX_FILE=/tmp/octave-debugger.vsix
    curl --compressed -L -o ${VSIX_FILE} https://marketplace.visualstudio.com/_apis/public/gallery/publishers/paulosilva/vsextensions/vsc-octave-debugger/${VSIX_VERSION}/vspackage
    code-server --force --install-extension ${VSIX_FILE}
    rm ${VSIX_FILE}

    # Download the Octave Jupyter Kernel (see https://github.com/calysto/octave_kernel#installation)
    pip3 install octave_kernel
}
