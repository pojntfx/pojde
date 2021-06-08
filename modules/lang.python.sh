#!/bin/bash

# Root script
function as_root() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Set pip3 as default pip (Python 2 is EOL)
    update-alternatives --install /usr/bin/pip pip /usr/bin/pip3 1

    # Add Python's bin directory to PATH using profile
    CONFIG_FILE=/etc/profile.d/python.sh
    cat <<EOT >$CONFIG_FILE
export PATH=\$PATH:/root/.local/bin
export PATH=\$PATH:/home/${POJDE_USERNAME}/.local/bin
EOT
    chmod +x ${CONFIG_FILE}

    # Add Python's bin directory to both .bashrcs
    echo ". ${CONFIG_FILE}" >>/root/.bashrc
    echo ". ${CONFIG_FILE}" >>/home/${POJDE_USERNAME}/.bashrc
}

# User script
function as_user() {
    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the Python VSCode extension
    code-server --force --install-extension 'ms-python.python'
    code-server --force --install-extension 'littlefoxteam.vscode-python-test-adapter'
}
