# Config Files

## /etc/nginx/conf.d/default.conf

```conf
map $http_upgrade $connection_upgrade {
    default upgrade;
    '' close;
}

server {
    listen 8000;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host $host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}

server {
    listen 8001;

    location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $remote_addr;
        proxy_set_header Host $http_host;
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

server {
    listen 8002;

    location / {
        proxy_pass http://localhost:3002;
        proxy_set_header Host $host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection $connection_upgrade;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

## /etc/supervisord.conf

```conf
[supervisord]
nodaemon=true

[program:xvfb]
priority=100
command=/usr/bin/Xvfb :1 -screen 0 1024x800x24
user=root
autorestart=true

[program:x11vnc]
priority=200
command=x11vnc -rfbauth /etc/vncsecret -display :1 -xkb -noxrecord -noxfixes -noxdamage -wait 5 -shared
user=root
autorestart=true

[program:fluxbox]
priority=300
command=/usr/bin/fluxbox
user=root
autorestart=true
environment=DISPLAY=":1",HOME="/root",USER="root"

[program:novnc]
priority=400
command=/usr/bin/novnc_server --vnc localhost:5900 --listen 3002
user=root
autorestart=true

[program:nginx]
priority=500
command=/usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf
user=root
autorestart=true

[program:theia]
priority=600
directory=/root/Repos/felix-pojtingers-theia
command=/usr/bin/yarn theia start ~/Workspaces/workspace-one --hostname 127.0.0.1 --port 3000 --plugins=local-dir:plugins
user=root
autorestart=true

[program:gotty]
priority=700
command=/root/go/bin/gotty -p 3001 --address 127.0.0.1 -w sh
user=root
autorestart=true
```