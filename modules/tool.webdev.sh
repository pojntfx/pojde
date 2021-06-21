#!/bin/bash

# Root script
function as_root() {
    # Read versions
    . /opt/pojde/versions.sh

    # Install protoc
    apt install -y libprotobuf-dev protobuf-compiler

    # Install grpcurl
    VERSION="${GRPCURL_VERSION}"
    if [ "$(uname -m)" = 'x86_64' ]; then
        curl -L -o /tmp/grpcurl.tar.gz https://github.com/fullstorydev/grpcurl/releases/download/v${VERSION}/grpcurl_${VERSION}_linux_x86_64.tar.gz
    else
        curl -L -o /tmp/grpcurl.tar.gz https://github.com/fullstorydev/grpcurl/releases/download/v${VERSION}/grpcurl_${VERSION}_linux_arm64.tar.gz
    fi

    tar -C /usr/local/bin -xzf /tmp/grpcurl.tar.gz grpcurl
    chmod +x /usr/local/bin/grpcurl
    rm /tmp/grpcurl.tar.gz
}

# User script
function as_user() {
    # Read versions
    . /opt/pojde/versions.sh

    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the Web Development VSCode extensions
    code-server --force --install-extension 'zxh404.vscode-proto3'
    code-server --force --install-extension 'GraphQL.vscode-graphql'
    code-server --force --install-extension '42Crunch.vscode-openapi'
    code-server --force --install-extension 'dsznajder.es7-react-js-snippets'
    code-server --force --install-extension 'firefox-devtools.vscode-firefox-debug'
    code-server --force --install-extension 'jpoissonnier.vscode-styled-components'
    code-server --force --install-extension 'arcanis.vscode-zipfs'
    code-server --force --install-extension 'deerawan.vscode-faker'

    VERSION="${WEB_ACCESSIBILITY_EXTENSION_VERSION}"
    FILE=/tmp/web-accessibility.vsix
    curl --compressed -L -o ${FILE} https://marketplace.visualstudio.com/_apis/public/gallery/publishers/MaxvanderSchee/vsextensions/web-accessibility/${VERSION}/vspackage
    code-server --force --install-extension ${FILE}
    rm ${FILE}

    VERSION="${APOLLO_EXTENSION_VERSION}"
    FILE=/tmp/vscode-apollo.vsix
    curl --compressed -L -o ${FILE} https://marketplace.visualstudio.com/_apis/public/gallery/publishers/apollographql/vsextensions/vscode-apollo/${VERSION}/vspackage
    code-server --force --install-extension ${FILE}
    rm ${FILE}

    VERSION="${SCSS_EXTENSION_VERSION}"
    FILE=/tmp/vscode-scss.vsix
    curl --compressed -L -o ${FILE} https://github.com/mrmlnc/vscode-scss/releases/download/${VERSION}/vscode-scss-${VERSION}.vsix
    code-server --force --install-extension ${FILE}
    rm ${FILE}

    # Install wasmer
    curl https://get.wasmer.io -sSfL | sh
}
