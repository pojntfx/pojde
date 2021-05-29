#!/bin/bash

# Root script
function as_root() {
    # Install Octave
    apt install -y octave gnuplot
}

# User script
function as_user() {
    # Read versions
    . /opt/pojde/versions.sh

    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the Octave VSCode extensions
    VERSION="${OCTAVE_HACKING_EXTENSION_VERSION}"
    FILE=/tmp/octave-hacking.vsix
    curl --compressed -L -o ${FILE} https://marketplace.visualstudio.com/_apis/public/gallery/publishers/apjanke/vsextensions/octave-hacking/${VERSION}/vspackage
    code-server --force --install-extension ${FILE}
    rm ${FILE}

    VERSION="${OCTAVE_EXTENSION_VERSION}"
    FILE=/tmp/octave.vsix
    curl --compressed -L -o ${FILE} https://marketplace.visualstudio.com/_apis/public/gallery/publishers/toasty-technologies/vsextensions/octave/${VERSION}/vspackage
    code-server --force --install-extension ${FILE}
    rm ${FILE}

    VERSION="${OCTAVE_DEBUGGER_VERSION}"
    FILE=/tmp/octave-debugger.vsix
    curl --compressed -L -o ${FILE} https://marketplace.visualstudio.com/_apis/public/gallery/publishers/paulosilva/vsextensions/vsc-octave-debugger/${VERSION}/vspackage
    code-server --force --install-extension ${FILE}
    rm ${FILE}

    # Download the Octave Jupyter Kernel (see https://github.com/calysto/octave_kernel#installation)
    pip3 install octave_kernel
}
