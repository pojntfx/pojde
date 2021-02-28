#!/bin/bash

# Root script
function as_root() {
    # Install protoc
    apt install -y libprotobuf-dev protobuf-compiler
}

# User script
function as_user() {
    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the Web Development VSCode extensions
    code-server --force --install-extension 'zxh404.vscode-proto3'
    code-server --force --install-extension 'GraphQL.vscode-graphql'
    code-server --force --install-extension '42Crunch.vscode-openapi'
    code-server --force --install-extension 'dsznajder.es7-react-js-snippets'
    code-server --force --install-extension 'Orta.vscode-jest'
    code-server --force --install-extension 'firefox-devtools.vscode-firefox-debug'
    code-server --force --install-extension 'jpoissonnier.vscode-styled-components'
    code-server --force --install-extension 'arcanis.vscode-zipfs'
    code-server --force --install-extension 'deerawan.vscode-faker'

    VSIX_VERSION=0.2.83
    VSIX_FILE=/tmp/web-accessibility.vsix
    curl --compressed -L -o ${VSIX_FILE} https://marketplace.visualstudio.com/_apis/public/gallery/publishers/MaxvanderSchee/vsextensions/web-accessibility/${VSIX_VERSION}/vspackage
    code-server --force --install-extension ${VSIX_FILE}
    rm ${VSIX_FILE}

    # Install wasmer
    curl https://get.wasmer.io -sSfL | sh
}
