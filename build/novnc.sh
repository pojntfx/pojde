#!/bin/bash

# Install XFCE4 and dependencies
apt install -y xvfb xfce4 x11vnc novnc net-tools onboard

# Add temporary password
x11vnc -storepasswd changeme /etc/vncsecret

# Create systemd service for Xvfb
cat <<EOT >/usr/lib/systemd/system/xvfb.service
[Unit]
Description=Xvfb

[Service]
Type=simple
ExecStart=/usr/bin/Xvfb :1 -screen 0 1280x720x24 +iglx

[Install]
WantedBy=multi-user.target
EOT

# Create systemd service for XFCE4
cat <<EOT >/usr/lib/systemd/system/xfce4.service
[Unit]
Description=XFCE4

[Service]
Type=simple
ExecStart=/usr/bin/startxfce4
Environment="DISPLAY=:1"

[Install]
WantedBy=multi-user.target
EOT

# Create systemd service for x11vnc
cat <<EOT >/usr/lib/systemd/system/x11vnc.service
[Unit]
Description=x11vnc

[Service]
Type=simple
ExecStart=/usr/bin/x11vnc -display :1 -rfbauth /etc/vncsecret -forever

[Install]
WantedBy=multi-user.target
EOT

# Create systemd service for novnc
cat <<EOT >/usr/lib/systemd/system/novnc.service
[Unit]
Description=noVNC

[Service]
Type=simple
ExecStart=/usr/share/novnc/utils/launch.sh --vnc localhost:5900 --listen 3003

[Install]
WantedBy=multi-user.target
EOT
