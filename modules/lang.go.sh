#!/bin/bash

# Root script
function as_root() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Read versions
    . /opt/pojde/versions.sh

    # Fetch Go binary package
    VERSION="${GO_VERSION}"
    if [ "$(uname -m)" = 'x86_64' ]; then
        curl -L -o /tmp/go.tar.gz https://golang.org/dl/go${VERSION}.linux-amd64.tar.gz
    else
        curl -L -o /tmp/go.tar.gz https://golang.org/dl/go${VERSION}.linux-arm64.tar.gz
    fi

    # Extract the package to /usr/local
    tar -C /usr/local -xzf /tmp/go.tar.gz

    # Remove the extracted package
    rm /tmp/go.tar.gz

    # Fetch TinyGo binary package
    VERSION="${TINYGO_VERSION}"
    if [ "$(uname -m)" = 'x86_64' ]; then
        curl -L -o /tmp/tinygo.deb https://github.com/tinygo-org/tinygo/releases/download/v${VERSION}/tinygo_${VERSION}_amd64.deb
    else
        curl -L -o /tmp/tinygo.deb https://github.com/tinygo-org/tinygo/releases/download/v${VERSION}/tinygo_${VERSION}_arm.deb
    fi

    # Install the TinyGo binary package
    dpkg -i /tmp/tinygo.deb

    # Add Go and TinyGo to PATH using profile
    CONFIG_FILE=/etc/profile.d/go.sh
    cat <<EOT >$CONFIG_FILE
export PATH=\$PATH:/usr/local/go/bin
export PATH=\$PATH:/usr/local/tinygo/bin
export PATH=\$PATH:/home/${POJDE_USERNAME}/go/bin
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

    # Read versions
    . /opt/pojde/versions.sh

    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the Go VSCode extensions
    code-server --force --install-extension 'golang.Go'
    code-server --force --install-extension 'ethan-reesor.vscode-go-test-adapter'

    # Install the TinyGo VSCode extension
    VERSION="${TINYGO_EXTENSION_VERSION}"
    FILE=/tmp/tinygo.vsix
    curl -L -o ${FILE} https://github.com/tinygo-org/vscode-tinygo/releases/download/${VERSION}/vscode-tinygo-${VERSION}.vsix
    code-server --force --install-extension ${FILE}
    rm ${FILE}

    # Download the Go Jupyter Kernel (see https://github.com/gopherdata/gophernotes)
    env GO111MODULE=off go get -d -u github.com/gopherdata/gophernotes
    cd "$(go env GOPATH)"/src/github.com/gopherdata/gophernotes
    env GO111MODULE=on go install
    mkdir -p ~/.local/share/jupyter/kernels/gophernotes
    cp kernel/* ~/.local/share/jupyter/kernels/gophernotes
    cd ~/.local/share/jupyter/kernels/gophernotes
    chmod +w ./kernel.json # in case copied kernel.json has no write permission
    sed "s|gophernotes|$(go env GOPATH)/bin/gophernotes|" <kernel.json.in >kernel.json
}
