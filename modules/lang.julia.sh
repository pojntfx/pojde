#!/bin/bash

# Root script
function as_root() {
    # Read configuration file
    . /opt/pojde-ng/preferences/preferences.sh

    # Fetch Julia binary package
    JULIA_MAJOR_VERSION=1.5
    JULIA_MINOR_VERSION=3
    if [ "$(uname -m)" = 'x86_64' ]; then
        curl -L -o /tmp/julia.tar.gz https://julialang-s3.julialang.org/bin/linux/x64/${JULIA_MAJOR_VERSION}/julia-${JULIA_MAJOR_VERSION}.${JULIA_MINOR_VERSION}-linux-x86_64.tar.gz
    else
        curl -L -o /tmp/julia.tar.gz https://julialang-s3.julialang.org/bin/linux/aarch64/${JULIA_MAJOR_VERSION}/julia-${JULIA_MAJOR_VERSION}.${JULIA_MINOR_VERSION}-linux-aarch64.tar.gz
    fi

    # Extract the package to /usr/local
    tar -C /usr/local -xzf /tmp/julia.tar.gz

    # Remove the extracted package
    rm /tmp/julia.tar.gz

    # Add Julia to PATH using profile
    CONFIG_FILE=/etc/profile.d/julia.sh
    cat <<EOT >$CONFIG_FILE
export PATH=\$PATH:/usr/local/julia-${JULIA_MAJOR_VERSION}.${JULIA_MINOR_VERSION}/bin
EOT
    chmod +x ${CONFIG_FILE}

    # Add Julia to both .bashrcs
    echo ". ${CONFIG_FILE}" >>/root/.bashrc
    echo ". ${CONFIG_FILE}" >>/home/${POJDE_NG_USERNAME}/.bashrc

    # Restart JupyterLab and code-server (so that the new PATH is re-read)
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
    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the Julia VSCode extension
    code-server --force --install-extension 'julialang.language-julia'

    # Download the Julia Jupyter Kernel (see https://julialang.github.io/IJulia.jl/stable/manual/installation/#Installing-IJulia)
    julia -e 'using Pkg; Pkg.add("IJulia")'
}
