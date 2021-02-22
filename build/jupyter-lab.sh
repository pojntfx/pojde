#!/bin/bash

# Install pip
apt install -y python3-pip

# Install Jupyter Lab
pip3 install jupyterlab

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
