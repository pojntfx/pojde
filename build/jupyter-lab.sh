#!/bin/bash

# Install pip
apt install -y python3-pip

# Install Jupyter Lab
pip3 install jupyterlab

# Create services
if [ "${POJDE_NG_OPENRC}" = 'true' ]; then
    # Create OpenRC service with the listen port set to 38004
    cat <<EOT >/etc/init.d/jupyter-lab
#!/sbin/openrc-run                                                                                                                                                                                                    
name=\$RC_SVCNAME
command="/usr/bin/sudo"
command_args="-u \$(cat /opt/pojde-ng/jupyter-lab/user) /usr/local/bin/jupyter-lab --ip 127.0.0.1 --allow-root --port 38004 --no-browser --notebook-dir /home/\$(cat /opt/pojde-ng/jupyter-lab/user)/Notebooks"
pidfile="/run/\$RC_SVCNAME.pid"
command_background="yes"
EOT
    chmod +x /etc/init.d/jupyter-lab
else
    # Create systemd service with the listen port set to 38004
    cat <<EOT >/usr/lib/systemd/system/jupyter-lab@.service
[Unit]
Description=Jupyter Lab

[Service]
Type=simple
ExecStart=/usr/local/bin/jupyter-lab --ip 127.0.0.1 --port 38004 --no-browser --notebook-dir /home/%i/Notebooks
Restart=always
User=%i

[Install]
WantedBy=multi-user.target
EOT
fi
