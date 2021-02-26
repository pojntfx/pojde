#!/bin/bash

# Root script
function as_root() {
    # Read configuration file
    . /opt/pojde-ng/preferences/preferences.sh

    # Install C#
    DOTNET_ROOT=/home/${POJDE_NG_USERNAME}/.dotnet
    curl -L https://dot.net/v1/dotnet-install.sh | bash -s -- -c Current --install-dir ${DOTNET_ROOT}

    # Fix permissions
    chown -R ${POJDE_NG_USERNAME} ${DOTNET_ROOT}

    # Add C# tools to PATH using profile
    CONFIG_FILE=/etc/profile.d/csharp.sh
    cat <<EOT >$CONFIG_FILE
export DOTNET_ROOT=${DOTNET_ROOT}
export PATH=\$PATH:\${DOTNET_ROOT}
export PATH=\$PATH:\${DOTNET_ROOT}/tools
EOT
    chmod +x ${CONFIG_FILE}

    # Add C# tools to both .bashrcs
    echo ". ${CONFIG_FILE}" >>/root/.bashrc
    echo ". ${CONFIG_FILE}" >>/home/${POJDE_NG_USERNAME}/.bashrc

    # Restart Jupyter Lab (so that the new PATH is re-read)
    if [ "${POJDE_NG_OPENRC}" = 'true' ]; then
        rc-service jupyter-lab restart
        rc-service code-server restart
    else
        systemctl restart "jupyter-lab@${POJDE_NG_USERNAME}"
        systemctl restart "code-server@${POJDE_NG_USERNAME}"
    fi
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
