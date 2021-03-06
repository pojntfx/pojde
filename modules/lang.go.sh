#!/bin/bash

# Root script
function as_root() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Fetch Go binary package
    GO_VERSION=1.16
    if [ "$(uname -m)" = 'x86_64' ]; then
        curl -L -o /tmp/go.tar.gz https://golang.org/dl/go${GO_VERSION}.linux-amd64.tar.gz
    else
        curl -L -o /tmp/go.tar.gz https://golang.org/dl/go${GO_VERSION}.linux-arm64.tar.gz
    fi

    # Extract the package to /usr/local
    tar -C /usr/local -xzf /tmp/go.tar.gz

    # Remove the extracted package
    rm /tmp/go.tar.gz

    # Fetch TinyGo binary package
    TINYGO_VERSION=0.16.0
    if [ "$(uname -m)" = 'x86_64' ]; then
        curl -L -o /tmp/tinygo.deb https://github.com/tinygo-org/tinygo/releases/download/v${TINYGO_VERSION}/tinygo_${TINYGO_VERSION}_amd64.deb
    else
        curl -L -o /tmp/tinygo.deb https://github.com/tinygo-org/tinygo/releases/download/v${TINYGO_VERSION}/tinygo_${TINYGO_VERSION}_arm.deb
    fi

    # Install the TinyGo binary package
    dpkg -i /tmp/tinygo.deb

    # Add Go and TinyGo to PATH using profile
    CONFIG_FILE=/etc/profile.d/go.sh
    cat <<EOT >$CONFIG_FILE
export PATH=\$PATH:/usr/local/go/bin
export PATH=\$PATH:/usr/local/tinygo/bin
EOT
    chmod +x ${CONFIG_FILE}

    # Add Go and TinyGo to both .bashrcs
    echo ". ${CONFIG_FILE}" >>/root/.bashrc
    echo ". ${CONFIG_FILE}" >>/home/${POJDE_USERNAME}/.bashrc
}

# User script
function as_user() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the Go VSCode extensions
    code-server --force --install-extension 'golang.Go'
    code-server --force --install-extension 'ethan-reesor.vscode-go-test-adapter'

    # Install the TinyGo VSCode extension
    VSIX_VERSION=0.2.0
    VSIX_FILE=/tmp/tinygo.vsix
    curl -L -o ${VSIX_FILE} https://github.com/tinygo-org/vscode-tinygo/releases/download/${VSIX_VERSION}/vscode-tinygo-${VSIX_VERSION}.vsix
    code-server --force --install-extension ${VSIX_FILE}
    rm ${VSIX_FILE}

    # Download the Go Jupyter Kernel (see https://github.com/gopherdata/gophernotes)
    GOPHER_NOTES_VERSION=0.7.1
    env GO111MODULE=on go get github.com/gopherdata/gophernotes
    mkdir -p /home/${POJDE_USERNAME}/.local/share/jupyter/kernels/gophernotes
    cd /home/${POJDE_USERNAME}/.local/share/jupyter/kernels/gophernotes
    cp -rf "$(go env GOPATH)"/pkg/mod/github.com/gopherdata/gophernotes@v${GOPHER_NOTES_VERSION}/kernel/* "."
    chmod +w ./kernel.json # in case copied kernel.json has no write permission
    sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" <kernel.json.in >kernel.json
}
