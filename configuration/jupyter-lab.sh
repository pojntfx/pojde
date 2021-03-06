#!/bin/bash

# Upgrade script
function upgrade() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Create notebooks directory
    su - $POJDE_USERNAME -c "mkdir -p /home/${POJDE_USERNAME}/Notebooks"

    # Change the password to the new value and enable remote access without binding to all interfaces
    su - $POJDE_USERNAME -c "jupyter server --generate-config -y"
    CONFIG_FILE=/home/$POJDE_USERNAME/.jupyter/jupyter_server_config.py
    echo "c.NotebookApp.password='"$(python3 -c "from IPython.lib.security import passwd; print(passwd(passphrase='${POJDE_PASSWORD}', algorithm='sha1'))")"'" >>$CONFIG_FILE
    echo 'c.NotebookApp.allow_remote_access = True' >>$CONFIG_FILE
    echo "c.NotebookApp.allow_origin = '*'" >>$CONFIG_FILE

    # Copy JupyterLab assets to home directory and fix permissions
    if [ ! -d "/home/${POJDE_USERNAME}/.jupyter/lab" ]; then
        mkdir -p /home/${POJDE_USERNAME}/.jupyter/lab
        cp -rf /usr/local/share/jupyter/lab/* /home/${POJDE_USERNAME}/.jupyter/lab
        chown -R ${POJDE_USERNAME} /home/${POJDE_USERNAME}/.jupyter
    fi

    # Symlink the assets back and fix permissions
    rm -rf /usr/local/share/jupyter/lab
    ln -sf /home/${POJDE_USERNAME}/.jupyter/lab /usr/local/share/jupyter/lab
    chown -R ${POJDE_USERNAME} /usr/local/share/jupyter/lab

    # Enable & restart the services
    if [ "${POJDE_OPENRC}" = 'true' ]; then
        rc-service jupyter-lab restart
        rc-update add jupyter-lab default
    else
        systemctl enable "jupyter-lab@${POJDE_USERNAME}"
        systemctl restart "jupyter-lab@${POJDE_USERNAME}"
    fi
}

# Refresh script
function refresh() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Remove kernels
    rm -rf /home/${POJDE_USERNAME}/.local/share/jupyter/kernels/*
}
