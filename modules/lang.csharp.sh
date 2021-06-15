#!/bin/bash

# Root script
function as_root() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Install C#
    DOTNET_ROOT=/home/${POJDE_USERNAME}/.dotnet
    curl -L https://dot.net/v1/dotnet-install.sh | bash -s -- -c Current --install-dir ${DOTNET_ROOT}

    # Create the pfx cert
    CERTIFICATE_ROOT=${DOTNET_ROOT}/certificates
    mkdir -p ${CERTIFICATE_ROOT}
    openssl pkcs12 -export -out ${CERTIFICATE_ROOT}/server.pfx -inkey /etc/nginx/server.key -in /etc/nginx/server.crt -passout pass:

    # Fix permissions
    chown -R ${POJDE_USERNAME} ${DOTNET_ROOT}

    # Add C# tools to PATH and configure certificates using profile
    CONFIG_FILE=/etc/profile.d/csharp.sh
    cat <<EOT >$CONFIG_FILE
export DOTNET_ROOT=${DOTNET_ROOT}
export PATH=\$PATH:\${DOTNET_ROOT}
export PATH=\$PATH:\${DOTNET_ROOT}/tools
export CERTIFICATE_ROOT=\${DOTNET_ROOT}/certificates
export ASPNETCORE_Kestrel__Certificates__Default__Path="\${CERTIFICATE_ROOT}/server.pfx"
EOT
    chmod +x ${CONFIG_FILE}

    # Add C# tools to both .bashrcs
    echo ". ${CONFIG_FILE}" >>/root/.bashrc
    echo ". ${CONFIG_FILE}" >>/home/${POJDE_USERNAME}/.bashrc

    # Restart JupyterLab and code-server (so that the new PATH is re-read)
    if [ "${POJDE_OPENRC}" = 'true' ]; then
        rc-service jupyter-lab restart
        rc-service code-server restart
    else
        systemctl restart "jupyter-lab@${POJDE_USERNAME}"
        systemctl restart "code-server@${POJDE_USERNAME}"
    fi

    # Add PowerShell
    curl -L -o /tmp/packages-microsoft-prod.deb https://packages.microsoft.com/config/debian/10/packages-microsoft-prod.deb
    dpkg -i /tmp/packages-microsoft-prod.deb
    apt update
    apt install -y powershell
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

    # Install the C# VSCode extension
    code-server --force --install-extension 'muhammad-sammy.csharp'

    # Download the C# Jupyter Kernel (see https://github.com/dotnet/interactive/blob/main/docs/NotebooksLocalExperience.md#installing-net-interactive-as-a-jupyter-kernel)
    dotnet tool install -g --add-source "https://pkgs.dev.azure.com/dnceng/public/_packaging/dotnet-tools/nuget/v3/index.json" Microsoft.dotnet-interactive
    dotnet interactive jupyter install

    # Install the PowerShell VSCode extension
    VERSION="${POWERSHELL_EXTENSION_VERSION}"
    FILE=/tmp/pwsh.vsix
    curl -L -o ${FILE} https://github.com/PowerShell/vscode-powershell/releases/download/v${VERSION}/PowerShell-${VERSION}.vsix
    code-server --force --install-extension ${FILE}
    rm ${FILE}

    # Install the XML extension
    code-server --force --install-extension 'redhat.vscode-xml'
}
