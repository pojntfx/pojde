# Felicitas Pojtinger's Theia

My personal Theia distribution, optimized for full stack development.

## Overview

> Extensions marked with `(M)` have not yet been published to https://open-vsx.org/ and will be downloaded from the VSCode marketplace instead.

### Data and Documentation

- Markdown language basics
- Markdown language support
- YAML language basics
- YAML language support
- JSON language basics
- JSON language support
- Protobuf language support
- XML language basics
- XML language support

### Databases

- SQL language basics
- SQLTools (M)
- SQLTools PostgreSQL Driver (M)
- SQLTools SQLite Driver (M)
- SQLTools MySQL Driver (M)

### Scripting

- Shell Script language basics
- Shell Formatter (M)

### Collaboration and Comfort

- GitLens
- Git Graph
- Prettier
- Vim

### Go

- Go language basics
- Go language support

### JavaScript/TypeScript and Web Technologies

- JavaScript language basics
- TypeScript language basics
- TypeScript and JavaScript language features
- HTML language basics
- HTML language features
- CSS language basics
- CSS language features
- Styled Components
- Emmet
- ZipFS (M)

### Java

- Java language basics
- Java language support
- Debugger for Java
- Java test runner
- Maven for Java
- Project manager for Java
- JavaDoc Tools (M)

### Tools

The following additional tools are distributed alongside Theia to enable additional workflows:

- `gotty` Web Terminal to access `sh`
- `noVNC` Web VNC to access a Fluxbox-based desktop environment containing xterm and Chromium

## Usage

> Please use your own config values, such as IP addresses or SSH keys.

### Creating the virtual machine

First, we'll create a virtual machine that will serve as our base system using [alpimager](https://pojntfx.github.io/alpimager/):

```bash
cat <<EOT>packages.txt
openssh
sudo
curl
e2fsprogs-extra
EOT

cat <<EOT>repositories.txt
http://dl-cdn.alpinelinux.org/alpine/edge/main
http://dl-cdn.alpinelinux.org/alpine/edge/community
http://dl-cdn.alpinelinux.org/alpine/edge/testing
EOT

cat <<EOT>setup.sh
#!/bin/sh
setup-timezone -z UTC

cat <<-EOF >/etc/network/interfaces
iface lo inet loopback
iface eth0 inet dhcp
EOF

cat <<EOF >/etc/motd
Welcome to Felicitas Pojtinger's Alpine Linux Distribution!
EOF

mkdir -m 700 -p /root/.ssh
wget -O - https://github.com/pojntfx.keys | tee /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

ln -s networking /etc/init.d/net.lo
ln -s networking /etc/init.d/net.eth0

rc-update add sshd default
rc-update add net.eth0 default
rc-update add net.lo boot

sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/g' /etc/ssh/sshd_config
EOT

alpimager -output felicitas-pojtingers-theia.qcow2

qemu-img resize felicitas-pojtingers-theia.qcow2 +20G
```

### Starting the virtual machine

First, start the VM your host (use `-accel hvf` or `-accel hax` on macOS, `-accel kvm` on Linux). We'll enable port forwarding for SSH and Theia:

```bash
qemu-system-x86_64 -m 4096 -accel hax -nic user,hostfwd=tcp::40022-:22 -boot d -drive format=qcow2,file=felicitas-pojtingers-theia.qcow2
```

You can now SSH into the VM from your host and resize the filesystem:

```bash
ssh -p 40022 root@localhost resize2fs /dev/sda
```

### Setting up the environment

Now, let's install & compile (when necessary) the tools:

```bash
ssh -p 40022 root@localhost

apk add go nodejs npm yarn openjdk14 maven protoc build-base python3 git

wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
wget -O /tmp/glibc-2.32-r0.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-2.32-r0.apk
apk add /tmp/glibc-2.32-r0.apk

cat <<EOT>/etc/profile.d/java.sh
export JAVA_HOME="/usr/lib/jvm/java-14-openjdk"
export PATH="$JAVA_HOME/bin:$PATH"
export PATH="/root/go/bin:$PATH"
EOT
chmod +x /etc/profile.d/java.sh

mkdir -p ~/Repos/felicitas-pojtingers-theia
cd ~/Repos/felicitas-pojtingers-theia

cat <<EOT>package.json
{
  "name": "@pojntfx/felicitas-pojtingers-theia",
  "version": "0.0.1-alpha1",
  "description": "Felicitas Pojtinger's Theia IDE",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "Felicitas Pojtinger <felicitas@pojtinger.com>",
  "license": "AGPL-3.0",
  "theia": {
    "frontend": {
      "config": {
        "applicationName": "Felicitas Pojtinger's Theia"
      }
    }
  },
  "dependencies": {
    "@theia/callhierarchy": "next",
    "@theia/console": "next",
    "@theia/core": "next",
    "@theia/cpp-debug": "next",
    "@theia/debug": "next",
    "@theia/editor": "next",
    "@theia/editor-preview": "next",
    "@theia/file-search": "next",
    "@theia/filesystem": "next",
    "@theia/getting-started": "next",
    "@theia/git": "next",
    "@theia/keymaps": "next",
    "@theia/markers": "next",
    "@theia/messages": "next",
    "@theia/metrics": "next",
    "@theia/mini-browser": "next",
    "@theia/monaco": "next",
    "@theia/navigator": "next",
    "@theia/outline-view": "next",
    "@theia/output": "next",
    "@theia/plugin": "next",
    "@theia/plugin-ext": "next",
    "@theia/plugin-ext-vscode": "next",
    "@theia/preferences": "next",
    "@theia/preview": "next",
    "@theia/process": "next",
    "@theia/scm": "next",
    "@theia/search-in-workspace": "next",
    "@theia/task": "next",
    "@theia/terminal": "next",
    "@theia/typehierarchy": "next",
    "@theia/userstorage": "next",
    "@theia/variable-resolver": "next",
    "@theia/vsx-registry": "next",
    "@theia/workspace": "next"
  },
  "devDependencies": {
    "@theia/cli": "next"
  }
}
EOT

mkdir -p plugins

curl --compressed -L -o plugins/vscode.markdown.vsix https://open-vsx.org/api/vscode/markdown/1.48.2/file/vscode.markdown-1.48.2.vsix
curl --compressed -L -o plugins/vscode.markdown-language-features.vsix https://open-vsx.org/api/vscode/markdown-language-features/1.48.2/file/vscode.markdown-language-features-1.48.2.vsix
curl --compressed -L -o plugins/vscode.yaml.vsix https://open-vsx.org/api/vscode/yaml/1.48.2/file/vscode.yaml-1.48.2.vsix
curl --compressed -L -o plugins/redhat.vscode-yaml.vsix https://open-vsx.org/api/redhat/vscode-yaml/0.10.1/file/redhat.vscode-yaml-0.10.1.vsix
curl --compressed -L -o plugins/vscode.json.vsix https://open-vsx.org/api/vscode/json/1.48.2/file/vscode.json-1.48.2.vsix
curl --compressed -L -o plugins/vscode.json-language-features.vsix https://open-vsx.org/api/vscode/json-language-features/1.48.2/file/vscode.json-language-features-1.48.2.vsix
curl --compressed -L -o plugins/zxh404.vscode-proto3.vsix https://open-vsx.org/api/zxh404/vscode-proto3/0.4.2/file/zxh404.vscode-proto3-0.4.2.vsix
curl --compressed -L -o plugins/vscode.xml.vsix https://open-vsx.org/api/vscode/xml/1.48.2/file/vscode.xml-1.48.2.vsix
curl --compressed -L -o plugins/redhat.vscode-xml.vsix https://open-vsx.org/api/redhat/vscode-xml/0.13.0/file/redhat.vscode-xml-0.13.0.vsix
curl --compressed -L -o plugins/vscode.sql.vsix https://open-vsx.org/api/vscode/sql/1.48.2/file/vscode.sql-1.48.2.vsix
curl --compressed -L -o plugins/sqltools.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools/0.23.0/vspackage
curl --compressed -L -o plugins/sqltools-driver-pg.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-pg/0.2.0/vspackage
curl --compressed -L -o plugins/sqltools-driver-sqlite.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-sqlite/0.2.0/vspackage
curl --compressed -L -o plugins/sqltools-driver-mysql.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-mysql/0.2.0/vspackage
curl --compressed -L -o plugins/vscode.shellscript.vsix https://open-vsx.org/api/vscode/shellscript/1.48.2/file/vscode.shellscript-1.48.2.vsix
curl --compressed -L -o plugins/shell-format.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/foxundermoon/vsextensions/shell-format/7.0.1/vspackage
curl --compressed -L -o plugins/eamodio.gitlens.vsix https://open-vsx.org/api/eamodio/gitlens/10.2.1/file/eamodio.gitlens-10.2.1.vsix
curl --compressed -L -o plugins/mhutchie.git-graph.vsix https://open-vsx.org/api/mhutchie/git-graph/1.25.0/file/mhutchie.git-graph-1.25.0.vsix
curl --compressed -L -o plugins/esbenp.prettier-vscode.vsix https://open-vsx.org/api/esbenp/prettier-vscode/5.5.0/file/esbenp.prettier-vscode-5.5.0.vsix
curl --compressed -L -o plugins/vscodevim.vim.vsix https://open-vsx.org/api/vscodevim/vim/1.16.0/file/vscodevim.vim-1.16.0.vsix
curl --compressed -L -o plugins/vscode.go.vsix https://open-vsx.org/api/vscode/go/1.48.2/file/vscode.go-1.48.2.vsix
curl --compressed -L -o plugins/golang.Go.vsix https://open-vsx.org/api/golang/Go/0.16.1/file/golang.Go-0.16.1.vsix
curl --compressed -L -o plugins/vscode.javascript.vsix https://open-vsx.org/api/vscode/javascript/1.48.2/file/vscode.javascript-1.48.2.vsix
curl --compressed -L -o plugins/vscode.typescript.vsix https://open-vsx.org/api/vscode/typescript/1.48.2/file/vscode.typescript-1.48.2.vsix
curl --compressed -L -o plugins/vscode.typescript-language-features.vsix https://open-vsx.org/api/vscode/typescript-language-features/1.48.2/file/vscode.typescript-language-features-1.48.2.vsix
curl --compressed -L -o plugins/vscode.html.vsix https://open-vsx.org/api/vscode/html/1.48.2/file/vscode.html-1.48.2.vsix
curl --compressed -L -o plugins/vscode.html-language-features.vsix https://open-vsx.org/api/vscode/html-language-features/1.48.2/file/vscode.html-language-features-1.48.2.vsix
curl --compressed -L -o plugins/vscode.css.vsix https://open-vsx.org/api/vscode/css/1.48.2/file/vscode.css-1.48.2.vsix
curl --compressed -L -o plugins/vscode.css-language-features.vsix https://open-vsx.org/api/vscode/css-language-features/1.48.2/file/vscode.css-language-features-1.48.2.vsix
curl --compressed -L -o plugins/jpoissonnier.vscode-styled-components.vsix https://open-vsx.org/api/jpoissonnier/vscode-styled-components/0.0.29/file/jpoissonnier.vscode-styled-components-0.0.29.vsix
curl --compressed -L -o plugins/vscode.emmet.vsix https://open-vsx.org/api/vscode/emmet/1.48.2/file/vscode.emmet-1.48.2.vsix
curl --compressed -L -o plugins/vscode-zipfs.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/arcanis/vsextensions/vscode-zipfs/2.0.0/vspackage
curl --compressed -L -o plugins/vscode.java.vsix https://open-vsx.org/api/vscode/java/1.48.2/file/vscode.java-1.48.2.vsix
curl --compressed -L -o plugins/redhat.java.vsix https://open-vsx.org/api/redhat/java/0.66.0/file/redhat.java-0.66.0.vsix
curl --compressed -L -o plugins/vscjava.vscode-java-debug.vsix https://open-vsx.org/api/vscjava/vscode-java-debug/0.28.0/file/vscjava.vscode-java-debug-0.28.0.vsix
curl --compressed -L -o plugins/vscjava.vscode-java-test.vsix https://open-vsx.org/api/vscjava/vscode-java-test/0.24.1/file/vscjava.vscode-java-test-0.24.1.vsix
curl --compressed -L -o plugins/vscjava.vscode-maven.vsix https://open-vsx.org/api/vscjava/vscode-maven/0.21.2/file/vscjava.vscode-maven-0.21.2.vsix
curl --compressed -L -o plugins/vscjava.vscode-java-dependency.vsix https://open-vsx.org/api/vscjava/vscode-java-dependency/0.12.0/file/vscjava.vscode-java-dependency-0.12.0.vsix
curl --compressed -L -o plugins/vscode-javadoc-tools.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/madhavd1/vsextensions/javadoc-tools/1.4.0/vspackage

cd plugins
for z in *.vsix; do mkdir -p $z-extracted; unzip $z -d $z-extracted; rm $z; done
cd ..

mkdir -p ~/Workspaces/workspace-one

export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1
export NODE_OPTIONS="--max-old-space-size=8192"

fallocate -l 5G /swapfile
chmod 600 /swapfile
mkswap /swapfile
swapon /swapfile

yarn
yarn theia build

go get github.com/yudai/gotty

apk add supervisor xvfb x11vnc fluxbox novnc chromium xterm

x11vnc -storepasswd myvncpassword /etc/vncsecret

apk add nginx

cat <<EOT>/etc/nginx/conf.d/default.conf
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    '' close;
}

server {
    listen 8000;

    location / {
        proxy_pass http://localhost:3000;
        proxy_set_header Host \$host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}

server {
    listen 8001;

    location / {
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$remote_addr;
        proxy_set_header Host \$http_host;
        proxy_pass http://127.0.0.1:3001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}

server {
    listen 8002;

    location / {
        proxy_pass http://localhost:3002;
        proxy_set_header Host \$host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOT

cat <<EOT>/etc/supervisord.conf
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
directory=/root/Repos/felicitas-pojtingers-theia
command=/usr/bin/yarn theia start ~/Workspaces/workspace-one --hostname 127.0.0.1 --port 3000 --plugins=local-dir:plugins
user=root
autorestart=true

[program:gotty]
priority=700
command=/root/go/bin/gotty -p 3001 --address 127.0.0.1 -w sh
user=root
autorestart=true
EOT
```

### Starting all tools

Now, let's start the tooling & enable automatic startup on boot:

```bash
rc-service supervisord restart
rc-update add supervisord default
```

### Access the tools

You're done! All tools should now be running, but you still have to set up access to them:

```bash
ssh -L localhost:8000:localhost:8000 -L localhost:8001:localhost:8001 -L localhost:8002:localhost:8002 -p 40022 root@localhost
```

Now, you can access them like so:

| Tool name | Tool address          | Tool notes                                                                         |
| --------- | --------------------- | ---------------------------------------------------------------------------------- |
| Theia     | http://localhost:8000 | -                                                                                  |
| gotty     | http://localhost:8001 | -                                                                                  |
| noVNC     | http://localhost:8002 | Use password `myvncpassword` and start Chrome with `chromium-browser --no-sandbox` |

If you want too, you can of course also add port forwarding to QEMU directly as shown above for port 22 to 40022 and skip SSH forwarding, but be aware that there might be issues with Theia Webviews. These should be resolved by using SSH to forward to localhost as shown in the command above; in the future, I'll demonstrate setting up HTTPS to fix the issue properly.

## Missing Features

- Basic Auth (planned)
- HTTPS (planned)

## License

Felicitas Pojtinger's Theia (c) 2020 Felicitas Pojtinger

SPDX-License-Identifier: AGPL-3.0
