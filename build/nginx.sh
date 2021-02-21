#!/bin/bash

# Install nginx
apt install -y nginx

# Add map for WebSocket upgrades
cat <<EOT >/etc/nginx/conf.d/pojde-ng.conf
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    '' close;
}
EOT

# Create server blocks for ports 8000-8004
ports=(
    8000
    8001
    8002
    8003
    8004
)

for port in "${ports[@]}"; do
    cat <<EOT >>/etc/nginx/conf.d/pojde-ng.conf
server {
    listen ${port};

    location / {
        proxy_pass http://localhost:3${port};
        proxy_set_header Host \$host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOT
done

# Add block for SSH
cat <<EOT >/etc/nginx/modules-enabled/pojde-ng.conf
stream {
    upstream ssh {
        server localhost:38022;
    }
    server {
        listen 8022;
        proxy_pass ssh;
    }
}
EOT
