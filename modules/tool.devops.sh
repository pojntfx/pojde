#!/bin/bash

# Root script
function as_root() {
    # Read versions
    . /opt/pojde/versions.sh

    # Install QEMU
    apt install -y qemu qemu-kvm

    # Install kubectl and helm
    curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" >/etc/apt/sources.list.d/kubernetes.list
    curl https://baltocdn.com/helm/signing.asc | apt-key add -
    echo "deb https://baltocdn.com/helm/stable/debian/ all main" >/etc/apt/sources.list.d/helm.list
    apt update
    apt install -y kubectl helm

    # Install k9s
    VERSION="${K9S_VERSION}"
    if [ "$(uname -m)" = 'x86_64' ]; then
        curl -L -o /tmp/k9s.tar.gz https://github.com/derailed/k9s/releases/download/v${VERSION}/k9s_v${VERSION}_Linux_x86_64.tar.gz
    else
        curl -L -o /tmp/k9s.tar.gz https://github.com/derailed/k9s/releases/download/v${VERSION}/k9s_v${VERSION}_Linux_arm64.tar.gz
    fi
    tar -C /usr/local/bin -xzf /tmp/k9s.tar.gz k9s
    chmod +x /usr/local/bin/k9s
    rm /tmp/k9s.tar.gz

    # Install skaffold
    if [ "$(uname -m)" = 'x86_64' ]; then
        curl -L -o /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
    else
        curl -L -o /usr/local/bin/skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-arm64
    fi
    chmod +x /usr/local/bin/skaffold

    # Install k3d
    curl -L https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash

    # Install k3sup
    curl -L https://get.k3sup.dev | sh
}

# User script
function as_user() {
    # Read versions
    . /opt/pojde/versions.sh

    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the Kubernetes, Docker and k3d VSCode extensions
    code-server --force --install-extension 'ms-kubernetes-tools.vscode-kubernetes-tools'
    code-server --force --install-extension 'ms-azuretools.vscode-docker'

    VERSION="${K3D_EXTENSION_VERSION}"
    FILE=/tmp/vscode-k3d.vsix
    curl -L -o ${FILE} https://github.com/inercia/vscode-k3d/releases/download/v${VERSION}/vscode-k3d.vsix
    code-server --force --install-extension ${FILE}
    rm ${FILE}
}
