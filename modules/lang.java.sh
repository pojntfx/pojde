#!/bin/bash

# Root script
function as_root() {
    # Read configuration file
    . /opt/pojde-ng/preferences/preferences.sh

    # Install Java, Maven and Gradle
    apt install -y default-jre default-jdk maven gradle

    # Download the Java Jupyter Kernel (see https://github.com/SpencerPark/IJava#install-pre-built-binary)
    VERSION=1.3.0
    curl -L -o /tmp/ijava.zip https://github.com/SpencerPark/IJava/releases/download/v${VERSION}/ijava-${VERSION}.zip
    unzip -d /tmp/ijava /tmp/ijava.zip
    python3 /tmp/ijava/install.py --sys-prefix
    rm -rf /tmp/ijava*
}

# User script
function as_user() {
    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install Java extensions
    code-server --install-extension 'vscjava.vscode-maven'
    code-server --install-extension 'vscjava.vscode-java-dependency'
    code-server --install-extension 'redhat.java'
    code-server --install-extension 'redhat.vscode-xml'
    code-server --install-extension 'vscjava.vscode-java-debug'
    code-server --install-extension 'vscjava.vscode-java-test'
}
