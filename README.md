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

## Usage

First, we'll use https://pojntfx.github.io/alpimager/ to get a custom Alpine Linux image; be sure to use your own SSH keys etc.:

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

First, start the VM your host (use `-accel hvf` or `-accel hax` on macOS, `-accel kvm` on Linux). We'll enable port forwarding for SSH and Theia:

```bash
qemu-system-x86_64 -m 4096 -accel hax -nic user,hostfwd=tcp::40022-:22,hostfwd=tcp::43000-:3000 -boot d -drive format=qcow2,file=felicitas-pojtingers-theia.qcow2
```

You can now SSH into the VM from your host and resize the filesystem:

```bash
ssh -p 40022 root@localhost resize2fs /dev/sda
```

Now, set up the environment in the VM:

```bash
ssh -p 40022 root@localhost

setup-xorg-base dwm chromium
echo "exec dwm" > ~/.xinitrc

apk add go nodejs npm yarn openjdk14 maven protoc build-base python3 openssl git

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
    "@theia/workspace": "next",
    "theia-middleware": "^0.1.2"
  },
  "devDependencies": {
    "@theia/cli": "next"
  }
}
EOT

cat <<EOT>ssl.cfg
[req]
distinguished_name = req_distinguished_name
x509_extensions = v3_req
prompt = no
[req_distinguished_name]
C = NZ
ST = AU
L = Auckland
O = Quonsepto
OU = MyDivision
CN = dev.felicitas.pojtinger.com
[v3_req]
keyUsage = critical, digitalSignature, keyAgreement
extendedKeyUsage = serverAuth
subjectAltName = @alt_names
[alt_names]
DNS.1 = dev.felicitas.pojtinger.com
EOT

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout FelicitasPojtingersTheiaKey.key -out FelicitasPojtingersTheiaCert.crt -config ssl.cfg -sha256
chmod 400 FelicitasPojtingersTheiaKey.key

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

yarn
yarn theia build
```

And finally, start Theia:

```bash
yarn theia start ~/Workspaces/workspace-one --hostname 0.0.0.0 --port 3000 --ssl --cert FelicitasPojtingersTheiaCert.crt --certkey FelicitasPojtingersTheiaKey.key --plugins=local-dir:plugins
```

You may now either use `xinit` to start dwm inside of the VM and browse to https://localhost:3000 using the Chromium browser you've installed in the VM (with `chromium-browser --no-sandbox`) or point the browser on your host to https://localhost:43000 to access Theia. If you want to reach another service inside the VM (say a development web server) from your host, you can use SSH port forwarding:

```bash
ssh -p 40022 root@localhost -L localhost:1234:localhost:1234
```

In a similar fashion, you can make services from your host accessible from the VM like so:

```bash
ssh -p 40022 root@localhost -R localhost:1234:localhost:1234
```

Now, let's setup some more comfort features, starting with `gotty`:

```bash
go get github.com/yudai/gotty

cat <<EOT>~/.gotty
permit_write = true
enable_tls = true
EOT

openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout ~/.gotty.key -out ~/.gotty.crt -config ssl.cfg -sha256
```

You may now start it like so:

```bash
gotty -c mygottyusername:mygottypassword sh
```

## License

Felicitas Pojtinger's Theia (c) 2020 Felicitas Pojtinger

SPDX-License-Identifier: AGPL-3.0
