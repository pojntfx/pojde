#!/bin/bash

# Install pip
apt install -y python3-pip

# Install Jupyter Lab
pip3 install jupyterlab

# Add temporary password and enable remote access without binding to all interfaces
jupyter server --generate-config
echo "c.NotebookApp.password='"$(python3 -c "from IPython.lib.security import passwd; print(passwd(passphrase='changeme', algorithm='sha1'))")"'" >>/root/.jupyter/jupyter_server_config.py
echo 'c.NotebookApp.allow_remote_access = True' >>/root/.jupyter/jupyter_server_config.py
echo "c.NotebookApp.allow_origin = '*'" >>/root/.jupyter/jupyter_server_config.py

# Create notebooks directory
mkdir -p /root/Notebooks

# Create systemd service with the listen port set to 38004
cat <<EOT >/usr/lib/systemd/system/jupyter-lab.service
[Unit]
Description=Jupyter Lab

[Service]
Type=simple
ExecStart=/usr/local/bin/jupyter-lab --ip 127.0.0.1 --port 38004 --allow-root --no-browser --notebook-dir /root/Notebooks

[Install]
WantedBy=multi-user.target
EOT
