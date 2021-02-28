#!/bin/bash

# Root script
function as_root() {
    # Install texlive-full and pandoc
    apt install -y texlive-full pandoc plantuml gnuplot
}

# User script
function as_user() {
    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the technical documentation extensions
    code-server --force --install-extension 'valentjn.vscode-ltex'
    code-server --force --install-extension 'James-Yu.latex-workshop'
    code-server --force --install-extension 'foam.foam-vscode'
    code-server --force --install-extension 'tchayen.markdown-links'
    code-server --force --install-extension 'yzhang.markdown-all-in-one'
    code-server --force --install-extension 'hediet.vscode-drawio'
    code-server --force --install-extension 'jock.svg'

    VSIX_VERSION=1.0.0
    VSIX_FILE=/tmp/pdf.vsix
    curl -L -o ${VSIX_FILE} https://github.com/tomoki1207/vscode-pdfviewer/releases/download/v${VSIX_VERSION}/pdf-${VSIX_VERSION}.vsix
    code-server --force --install-extension ${VSIX_FILE}
    rm ${VSIX_FILE}
}
