#!/bin/bash
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

ln -sf /bin/bash /bin/sh

apk add go

wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
wget -O /tmp/glibc-2.32-r0.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-2.32-r0.apk
apk add /tmp/glibc-2.32-r0.apk

cat <<EOT >/etc/profile.d/main.sh
export JAVA_HOME="/usr/lib/jvm/java-14-openjdk"
export PATH="\$JAVA_HOME/bin:\$PATH"
export PATH="/root/go/bin:\$PATH"
export DOTNET_ROOT="/root/.dotnet"
export PATH="\$DOTNET_ROOT:\$PATH"
EOT
chmod +x /etc/profile.d/main.sh

cat <<EOT >/root/.bashrc
source /etc/profile
EOT
chmod +x /root/.bashrc

mkdir -p ~/Repos/mono.git
git clone git@github.com:mono/mono.git ~/Repos/mono.git
cd ~/Repos/mono.git
git checkout mono-6.10.0.105
apk add gettext gettext-dev libtool
./autogen.sh --prefix=/usr/local --with-mcs-docs=no --with-sigaltstack=no --disable-nls
mkdir -p /usr/include/sys && touch /usr/include/sys/sysctl.h
sed -i 's/HAVE_DECL_PTHREAD_MUTEXATTR_SETPROTOCOL/0/' mono/utils/mono-os-mutex.h
make get-monolite-latest
make -j$(nproc)
make install

curl -L https://dot.net/v1/dotnet-install.sh | bash -s -- -c 3.0

mkdir -p /root/.omnisharp
cat <<EOT >/root/.omnisharp/omnisharp.json
{
   "MSBuild": {
       "UseLegacySdkResolver": true
   }
}
EOT

mkdir -p ~/Repos/lldb-mi
git clone git@github.com:lldb-tools/lldb-mi.git ~/Repos/lldb-mi
cd ~/Repos/lldb-mi
cmake .
cmake --build . --target install

mkdir -p ~/Repos/felicitas-pojtingers-theia
cd ~/Repos/felicitas-pojtingers-theia

cat <<EOT >package.json
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
          "workbench.colorTheme": "dark",
          "go.autocompleteUnimportedPackages": true,
          "go.useLanguageServer": true,
          "vim.debug.silent": true,
          "sqltools.useNodeRuntime": true,
          "files.enableTrash": false,
          "cmake.configureOnOpen": true,
          "cmake.debugConfig": {
            "type": "lldb-mi",
            "request": "launch",
            "target": "${command:cmake.launchTargetPath}",
            "args": [],
            "cwd": "${workspaceFolder}"
          },
          "java.home": "/usr/lib/jvm/java-14-openjdk",
          "files.exclude": {
            "**/.classpath": true,
            "**/.project": true,
            "**/.settings": true,
            "**/.factorypath": true
          },
          "omnisharp.useGlobalMono": "always"
        }
      }
    }
  },
  "dependencies": {
    "@theia/callhierarchy": "next",
    "@theia/console": "next",
    "@theia/core": "next",
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

curl --compressed -L -o plugins/eamodio.gitlens.vsix https://open-vsx.org/api/eamodio/gitlens/10.2.1/file/eamodio.gitlens-10.2.1.vsix
curl --compressed -L -o plugins/mhutchie.git-graph.vsix https://open-vsx.org/api/mhutchie/git-graph/1.25.0/file/mhutchie.git-graph-1.25.0.vsix
curl --compressed -L -o plugins/esbenp.prettier-vscode.vsix https://open-vsx.org/api/esbenp/prettier-vscode/5.5.0/file/esbenp.prettier-vscode-5.5.0.vsix
curl --compressed -L -o plugins/vscodevim.vim.vsix https://open-vsx.org/api/vscodevim/vim/1.16.0/file/vscodevim.vim-1.16.0.vsix
curl --compressed -L -o plugins/vscode.markdown.vsix https://open-vsx.org/api/vscode/markdown/1.48.2/file/vscode.markdown-1.48.2.vsix
curl --compressed -L -o plugins/vscode.markdown-language-features.vsix https://open-vsx.org/api/vscode/markdown-language-features/1.48.2/file/vscode.markdown-language-features-1.48.2.vsix
curl --compressed -L -o plugins/vscode.yaml.vsix https://open-vsx.org/api/vscode/yaml/1.48.2/file/vscode.yaml-1.48.2.vsix
curl --compressed -L -o plugins/redhat.vscode-yaml.vsix https://open-vsx.org/api/redhat/vscode-yaml/0.10.1/file/redhat.vscode-yaml-0.10.1.vsix
curl --compressed -L -o plugins/bungcip.better-toml.vsix https://open-vsx.org/api/bungcip/better-toml/0.3.2/file/bungcip.better-toml-0.3.2.vsix
curl --compressed -L -o plugins/vscode.json.vsix https://open-vsx.org/api/vscode/json/1.48.2/file/vscode.json-1.48.2.vsix
curl --compressed -L -o plugins/vscode.json-language-features.vsix https://open-vsx.org/api/vscode/json-language-features/1.48.2/file/vscode.json-language-features-1.48.2.vsix
curl --compressed -L -o plugins/zxh404.vscode-proto3.vsix https://open-vsx.org/api/zxh404/vscode-proto3/0.4.2/file/zxh404.vscode-proto3-0.4.2.vsix
curl --compressed -L -o plugins/Prisma.vscode-graphql.vsix https://open-vsx.org/api/Prisma/vscode-graphql/0.3.1/file/Prisma.vscode-graphql-0.3.1.vsix
curl --compressed -L -o plugins/vscode.xml.vsix https://open-vsx.org/api/vscode/xml/1.48.2/file/vscode.xml-1.48.2.vsix
curl --compressed -L -o plugins/redhat.vscode-xml.vsix https://open-vsx.org/api/redhat/vscode-xml/0.13.0/file/redhat.vscode-xml-0.13.0.vsix
curl --compressed -L -o plugins/vscode.shellscript.vsix https://open-vsx.org/api/vscode/shellscript/1.48.2/file/vscode.shellscript-1.48.2.vsix
curl --compressed -L -o plugins/shell-format.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/foxundermoon/vsextensions/shell-format/7.0.1/vspackage
curl --compressed -L -o plugins/vscode.cpp.vsix https://open-vsx.org/api/vscode/cpp/1.48.2/file/vscode.cpp-1.48.2.vsix
curl --compressed -L -o plugins/webfreak.debug.vsix https://open-vsx.org/api/webfreak/debug/0.25.0/file/webfreak.debug-0.25.0.vsix
curl --compressed -L -o plugins/llvm-vs-code-extensions.vscode-clangd.vsix https://open-vsx.org/api/llvm-vs-code-extensions/vscode-clangd/0.1.5/file/llvm-vs-code-extensions.vscode-clangd-0.1.5.vsix
curl --compressed -L -o plugins/twxs.cmake.vsix https://open-vsx.org/api/twxs/cmake/0.0.17/file/twxs.cmake-0.0.17.vsix
curl --compressed -L -o plugins/cmake-tools.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/cmake-tools/1.4.1/vspackage
curl --compressed -L -o plugins/vscode.make.vsix https://open-vsx.org/api/vscode/make/1.48.2/file/vscode.make-1.48.2.vsix
curl --compressed -L -o plugins/matepek.vscode-catch2-test-adapter.vsix https://open-vsx.org/api/matepek/vscode-catch2-test-adapter/3.4.1/file/matepek.vscode-catch2-test-adapter-3.4.1.vsix
curl --compressed -L -o plugins/vscode.rust.vsix https://open-vsx.org/api/vscode/rust/1.48.2/file/vscode.rust-1.48.2.vsix
curl --compressed -L -o plugins/rust-lang.rust.vsix https://open-vsx.org/api/rust-lang/rust/0.7.8/file/rust-lang.rust-0.7.8.vsix
curl --compressed -L -o plugins/vscode.go.vsix https://open-vsx.org/api/vscode/go/1.48.2/file/vscode.go-1.48.2.vsix
curl --compressed -L -o plugins/golang.Go.vsix https://open-vsx.org/api/golang/Go/0.16.1/file/golang.Go-0.16.1.vsix
curl --compressed -L -o plugins/vscode.java.vsix https://open-vsx.org/api/vscode/java/1.48.2/file/vscode.java-1.48.2.vsix
curl --compressed -L -o plugins/redhat.java.vsix https://open-vsx.org/api/redhat/java/0.66.0/file/redhat.java-0.66.0.vsix
curl --compressed -L -o plugins/vscjava.vscode-java-debug.vsix https://open-vsx.org/api/vscjava/vscode-java-debug/0.28.0/file/vscjava.vscode-java-debug-0.28.0.vsix
curl --compressed -L -o plugins/vscjava.vscode-java-test.vsix https://open-vsx.org/api/vscjava/vscode-java-test/0.24.1/file/vscjava.vscode-java-test-0.24.1.vsix
curl --compressed -L -o plugins/vscjava.vscode-maven.vsix https://open-vsx.org/api/vscjava/vscode-maven/0.21.2/file/vscjava.vscode-maven-0.21.2.vsix
curl --compressed -L -o plugins/vscjava.vscode-java-dependency.vsix https://open-vsx.org/api/vscjava/vscode-java-dependency/0.12.0/file/vscjava.vscode-java-dependency-0.12.0.vsix
curl --compressed -L -o plugins/vscode-javadoc-tools.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/madhavd1/vsextensions/javadoc-tools/1.4.0/vspackage
curl --compressed -L -o plugins/vscode.csharp.vsix https://open-vsx.org/api/vscode/csharp/1.48.2/file/vscode.csharp-1.48.2.vsix
curl --compressed -L -o plugins/muhammad-sammy.csharp.vsix https://open-vsx.org/api/muhammad-sammy/csharp/1.23.2/file/muhammad-sammy.csharp-1.23.2.vsix
curl --compressed -L -o plugins/mono-debug.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/mono-debug/0.15.8/vspackage
curl --compressed -L -o plugins/k--kato.docomment.vsix https://open-vsx.org/api/k--kato/docomment/0.1.18/file/k--kato.docomment-0.1.18.vsix
curl --compressed -L -o plugins/vscode.python.vsix https://open-vsx.org/api/vscode/python/1.48.2/file/vscode.python-1.48.2.vsix
curl --compressed -L -o plugins/ms-python.python.vsix https://open-vsx.org/api/ms-python/python/2020.8.105369/file/ms-python.python-2020.8.105369.vsix
curl --compressed -L -o plugins/vscode.ruby.vsix https://open-vsx.org/api/vscode/ruby/1.48.2/file/vscode.ruby-1.48.2.vsix
curl --compressed -L -o plugins/rebornix.ruby.vsix https://open-vsx.org/api/rebornix/ruby/0.27.0/file/rebornix.ruby-0.27.0.vsix
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
curl --compressed -L -o plugins/vscode.sql.vsix https://open-vsx.org/api/vscode/sql/1.48.2/file/vscode.sql-1.48.2.vsix
curl --compressed -L -o plugins/sqltools.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools/0.23.0/vspackage
curl --compressed -L -o plugins/sqltools-driver-pg.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-pg/0.2.0/vspackage
curl --compressed -L -o plugins/sqltools-driver-sqlite.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-sqlite/0.2.0/vspackage
curl --compressed -L -o plugins/sqltools-driver-mysql.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-mysql/0.2.0/vspackage

cd plugins
for z in *.vsix; do
    mkdir -p $z-extracted
    unzip $z -d $z-extracted
    rm $z
done
cd ..

mkdir -p ~/Workspaces/workspace-one

export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1
export NODE_OPTIONS="--max-old-space-size=8192"

yarn
yarn theia build

yarn global add wetty

x11vnc -storepasswd mysvcpassword /etc/vncsecret

fc-cache -f

openssl req -newkey rsa:2048 -x509 -nodes -keyout /etc/nginx/server.key -new -out /etc/nginx/server.crt -subj /CN=pojntfx.dev.alphahorizon.io -reqexts SAN -extensions SAN -config <(cat /etc/ssl/openssl.cnf <(printf '[SAN]\nsubjectAltName=@alt_names\n[ alt_names ]\nIP.1=100.64.154.245\nIP.2=100.64.154.247\nDNS.1=pojntfx.dev.alphahorizon.io\nDNS.2=*.pojntfx.dev.alphahorizon.io\nDNS.3=localhost\nDNS.4=*.webview.localhost')) -sha256 -days 3650

printf "pojntfx:$(openssl passwd -apr1 mysvcpassword)\n" >/etc/nginx/.htpasswd

cat <<EOT >/etc/nginx/conf.d/default.conf
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    '' close;
}

server {
    listen 8000 ssl;
    ssl_certificate      server.crt;
    ssl_certificate_key  server.key;
    server_name pojntfx.dev.alphahorizon.io;

    location / {
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$remote_addr;
        proxy_set_header Host \$http_host;
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";

        auth_basic "Protected Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}

server {
    listen 8001 ssl;
    ssl_certificate      server.crt;
    ssl_certificate_key  server.key;
    server_name pojntfx.dev.alphahorizon.io;

    location / {
        proxy_pass http://localhost:3001;
        proxy_set_header Host \$host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

        auth_basic "Protected Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}

server {
    listen 8002 ssl;
    ssl_certificate      server.crt;
    ssl_certificate_key  server.key;
    server_name pojntfx.dev.alphahorizon.io;

    location / {
        proxy_pass http://localhost:3002;
        proxy_set_header Host \$host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

        auth_basic "Protected Area";
        auth_basic_user_file /etc/nginx/.htpasswd;
    }
}
EOT

cat <<EOT >/etc/supervisord.conf
[supervisord]
nodaemon=true

[program:wetty]
priority=100
directory=/root
command=/usr/local/bin/wetty -p 3000 -c bash -b /
user=root
autorestart=true

[program:theia]
priority=200
directory=/root/Repos/felicitas-pojtingers-theia
command=/usr/bin/yarn theia start ~/Workspaces/workspace-one --hostname 127.0.0.1 --port 3001 --plugins=local-dir:plugins
user=root
autorestart=true

[program:xvfb]
priority=300
command=/usr/bin/Xvfb :1 -screen 0 1024x768x24
user=root
autorestart=true

[program:x11vnc]
priority=400
command=x11vnc -rfbauth /etc/vncsecret -display :1 -xkb -noxrecord -noxfixes -noxdamage -wait 5 -shared
user=root
autorestart=true

[program:fluxbox]
priority=500
command=/usr/bin/fluxbox
user=root
autorestart=true
environment=DISPLAY=":1",HOME="/root",USER="root"

[program:novnc]
priority=600
command=/usr/bin/novnc_server --vnc localhost:5900 --listen 3002
user=root
autorestart=true

[program:nginx]
priority=700
command=/bin/sh -c "mkdir -p /run/nginx && /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf"
user=root
autorestart=true
EOT

rc-update add supervisord default
