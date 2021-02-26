#!/bin/bash

# Root script
function as_root() {
    # Read configuration file
    . /opt/pojde-ng/preferences/preferences.sh

    # Fetch and install Microsoft keys package
    curl -L -o /tmp/packages-microsoft-prod.deb https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb
    dpkg -i /tmp/packages-microsoft-prod.deb
    rm /tmp/packages-microsoft-prod.deb

    # Install C#
    apt update
    apt install -y dotnet-sdk-5.0 aspnetcore-runtime-5.0

    # Add C# tools to PATH using profile
    CONFIG_FILE=/etc/profile.d/csharp.sh
    echo "export PATH=\$PATH:/home/${POJDE_NG_USERNAME}/.dotnet/tools" >${CONFIG_FILE}
    chmod +x ${CONFIG_FILE}

    # Add C# tools to both .bashrcs
    echo ". ${CONFIG_FILE}" >>/root/.bashrc
    echo ". ${CONFIG_FILE}" >>/home/${POJDE_NG_USERNAME}/.bashrc

    # Restart Jupyter Lab (so that the new PATH is re-read)
    systemctl restart jupyter-lab@${POJDE_NG_USERNAME}
}

# User script
function as_user() {
    # Read configuration file
    . /opt/pojde-ng/preferences/preferences.sh

    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the C# VSCode extension
    code-server --install-extension 'muhammad-sammy.csharp'

    # Download the C# Jupyter Kernel (see https://github.com/dotnet/interactive/blob/main/docs/NotebooksLocalExperience.md#installing-net-interactive-as-a-jupyter-kernel)
    dotnet tool install -g --add-source "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json" Microsoft.dotnet-interactive
    dotnet interactive jupyter install
}
