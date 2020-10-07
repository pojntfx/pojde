#!/bin/bash

## Configure your IDE here
if [ -z ${FULL_NAME+x} ]; then export FULL_NAME="Felicitas Pojtinger"; fi
if [ -z ${MOTD+x} ]; then export MOTD="Welcome to ${FULL_NAME}'s Alpine Linux Distribution!"; fi
if [ -z ${IDE_DESCRIPTION+x} ]; then export IDE_DESCRIPTION="${FULL_NAME}'s Theia IDE"; fi
if [ -z ${EMAIL+x} ]; then export EMAIL="felicitas@pojtinger.com"; fi
if [ -z ${GITHUB_USERNAME+x} ]; then export GITHUB_USERNAME="pojntfx"; fi # For your public SSH keys
if [ -z ${USERNAME+x} ]; then export USERNAME="pojntfx"; fi               # For accessing the IDE
if [ -z ${PASSWORD+x} ]; then export PASSWORD="mysvcpassword"; fi         # For accessing the IDE
if [ -z ${IDE_NAME+x} ]; then export IDE_NAME="felicitas-pojtingers-theia"; fi
if [ -z ${DOMAIN+x} ]; then export DOMAIN="pojntfx.dev.alphahorizon.io"; fi            # Used for TLS SAN extensions; `localhost` is always included. Keep as is if you don't have a domain.
if [ -z ${IP+x} ]; then export IP="100.64.154.245"; fi                                 # Used for TLS SAN extensions. Keep as is if you don't know the IP of the target machine.
if [ -z ${ENABLE_OS_SETUP+x} ]; then export ENABLE_OS_SETUP="1"; fi                    # Set to "0" if you're not running this on a fresh system
if [ -z ${ENABLE_CSHARP_SUPPORT+x} ]; then export export ENABLE_CSHARP_SUPPORT="1"; fi # Set to "0" if you don't want C# support; compiling Mono can take some time.
## You shouldn't have to change anything below

if [ $ENABLE_OS_SETUP = "1" ]; then
    setup-timezone -z UTC

    cat <<-EOF >/etc/network/interfaces
iface lo inet loopback
iface eth0 inet dhcp
EOF

    cat <<EOF >/etc/motd
${MOTD}
EOF

    ln -s networking /etc/init.d/net.lo
    ln -s networking /etc/init.d/net.eth0

    rc-update add sshd default
    rc-update add net.eth0 default
    rc-update add net.lo boot
fi

mkdir -m 700 -p /root/.ssh
wget -O - https://github.com/${GITHUB_USERNAME}.keys | tee /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/g' /etc/ssh/sshd_config

ln -sf /bin/bash /bin/sh

apk add go

mkdir -p /usr/lib/go/misc/wasm/
curl -L -o /usr/lib/go/misc/wasm/wasm_exec.js https://raw.githubusercontent.com/golang/go/master/misc/wasm/wasm_exec.js

rustup-init -y

wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
wget -O /tmp/glibc-2.32-r0.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-2.32-r0.apk
apk add /tmp/glibc-2.32-r0.apk

cat <<EOT >/etc/profile.d/main.sh
export JAVA_HOME="/usr/lib/jvm/java-14-openjdk"
export PATH="\$JAVA_HOME/bin:\$PATH"
export PATH="/root/go/bin:\$PATH"
export DOTNET_ROOT="/usr/share/dotnet"
export PATH="\$DOTNET_ROOT:\$PATH"
export LIBRARY_PATH="/lib:/usr/lib"
export PATH="/root/.cargo/bin:\$PATH"
export CGO_CFLAGS="-g -O2 -Wno-return-local-addr"

ulimit -n 65000
EOT
chmod +x /etc/profile.d/main.sh

cat <<EOT >/root/.bashrc
source /etc/profile
EOT
chmod +x /root/.bashrc

if [ $ENABLE_CSHARP_SUPPORT = "1" ]; then
    rm -rf ~/Repos/mono.git
    mkdir -p ~/Repos/mono.git
    git clone https://github.com/mono/mono.git ~/Repos/mono.git
    cd ~/Repos/mono.git
    git checkout mono-6.10.0.105
    apk add gettext gettext-dev libtool
    ./autogen.sh --prefix=/usr/local --with-mcs-docs=no --with-sigaltstack=no --disable-nls
    mkdir -p /usr/include/sys && touch /usr/include/sys/sysctl.h
    sed -i 's/HAVE_DECL_PTHREAD_MUTEXATTR_SETPROTOCOL/0/' mono/utils/mono-os-mutex.h
    make get-monolite-latest
    make -j$(nproc)
    make install

    curl -L https://dot.net/v1/dotnet-install.sh | bash -s -- -c Current --install-dir /usr/share/dotnet
    ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet
fi

rm -rf ~/Repos/lldb-mi
mkdir -p ~/Repos/lldb-mi
git clone https://github.com/lldb-tools/lldb-mi.git ~/Repos/lldb-mi
cd ~/Repos/lldb-mi
cmake .
cmake --build . --target install

echo fs.inotify.max_user_watches=524288 | tee /etc/sysctl.d/inotify && sysctl -p

gvfs_pkgs=$(apk search gvfs -q | grep -v '\-dev' | grep -v '\-lang' | grep -v '\-doc')
apk add $gvfs_pkgs
ttfs=$(apk search -q ttf- | grep -v '\-doc')
apk add $ttfs

mkdir -p ~/Desktop

cat <<EOT >~/Desktop/Chromium.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Chromium
Comment=Access the Internet
Exec=chromium-browser --no-sandbox %U
Icon=chromium
Path=
Terminal=false
StartupNotify=false
EOT

cat <<EOT >~/Desktop/Onboard.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Onboard
Comment=Flexible onscreen keyboard
Exec=onboard
Icon=onboard
Path=
Terminal=false
StartupNotify=false
EOT

curl -L -o /usr/share/backgrounds/xfce/spacex.jpg 'https://images.unsplash.com/photo-1541185934-01b600ea069c?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&dl=spacex-6SbFGnQTE8s-unsplash.jpg'
xfconf-query -c xfce4-desktop -l | grep last-image | while read path; do xfconf-query -c xfce4-desktop -p $path -s /usr/share/backgrounds/xfce/spacex.jpg; done

rc-update add dbus default
rc-update add udev default
rc-update add fuse default

mkdir -p ~/.theia

cat <<EOT >~/.theia/keymaps.json
[
    {
        "command": "-file.rename",
        "keybinding": "f2",
        "context": "navigatorActive",
        "resolved": [
            {
                "key": {
                    "code": "F2",
                    "keyCode": 113,
                    "easyString": "f2"
                },
                "ctrl": false,
                "shift": false,
                "alt": false,
                "meta": false
            }
        ],
        "scope": 1
    },
    {
        "command": "file.rename",
        "keybinding": "alt+r",
        "context": "navigatorActive",
        "resolved": [
            {
                "key": {
                    "code": "KeyR",
                    "keyCode": 82,
                    "easyString": "r"
                },
                "ctrl": false,
                "shift": false,
                "alt": true,
                "meta": false
            }
        ],
        "scope": 1
    },
    {
        "command": "editor.action.rename",
        "keybinding": "alt+r",
        "when": "editorHasRenameProvider && editorTextFocus && !editorReadonly"
    },
    {
        "command": "-editor.action.rename",
        "keybinding": "f2",
        "when": "editorHasRenameProvider && editorTextFocus && !editorReadonly"
    }
]
EOT

mkdir -p ~/Repos/${IDE_NAME}
cd ~/Repos/${IDE_NAME}

cat <<EOT >package.json
{
  "name": "@${USERNAME}/${IDE_NAME}",
  "version": "0.0.1-alpha1",
  "description": "${IDE_DESCRIPTION}",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "${FULL_NAME} <${EMAIL}>",
  "license": "AGPL-3.0",
  "theia": {
    "frontend": {
      "config": {
        "applicationName": "${IDE_DESCRIPTION}",
        "preferences": {
           "workbench.colorTheme": "light",
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
             "**/.git": true,
             "**/.classpath": true,
             "**/.project": true,
             "**/.settings": true,
             "**/.factorypath": true
           },
           "omnisharp.useGlobalMono": "always",
           "godot_tools.editor_path": "/usr/bin/godot",
           "typescript.updateImportsOnFileMove.enabled": "always",
           "terminal.integrated.shell.linux": "/bin/bash",
           "testMate.cpp.log.logSentry": "disable_3",
           "npm.packageManager": "yarn",
           "firefox.executable": "/usr/bin/firefox",
           "editor.cursorSmoothCaretAnimation": true,
           "editor.smoothScrolling": true
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

rm -rf plugins
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
if [ $ENABLE_CSHARP_SUPPORT = "1" ]; then
    curl --compressed -L -o plugins/vscode.csharp.vsix https://open-vsx.org/api/vscode/csharp/1.48.2/file/vscode.csharp-1.48.2.vsix
    curl --compressed -L -o plugins/omnisharp_theia_plugin.vsix https://github.com/redhat-developer/omnisharp-theia-plugin/releases/download/v0.0.6/omnisharp_theia_plugin.theia
    curl --compressed -L -o plugins/mono-debug.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/ms-vscode/vsextensions/mono-debug/0.15.8/vspackage
    curl --compressed -L -o plugins/k--kato.docomment.vsix https://open-vsx.org/api/k--kato/docomment/0.1.18/file/k--kato.docomment-0.1.18.vsix
fi
curl --compressed -L -o plugins/vscode.python.vsix https://open-vsx.org/api/vscode/python/1.48.2/file/vscode.python-1.48.2.vsix
curl --compressed -L -o plugins/ms-python.python.vsix https://open-vsx.org/api/ms-python/python/2020.8.105369/file/ms-python.python-2020.8.105369.vsix
curl --compressed -L -o plugins/vscode.ruby.vsix https://open-vsx.org/api/vscode/ruby/1.48.2/file/vscode.ruby-1.48.2.vsix
curl --compressed -L -o plugins/rebornix.ruby.vsix https://open-vsx.org/api/rebornix/ruby/0.27.0/file/rebornix.ruby-0.27.0.vsix
curl --compressed -L -o plugins/vscode.javascript.vsix https://open-vsx.org/api/vscode/javascript/1.48.2/file/vscode.javascript-1.48.2.vsix
curl --compressed -L -o plugins/vscode.typescript.vsix https://open-vsx.org/api/vscode/typescript/1.48.2/file/vscode.typescript-1.48.2.vsix
curl --compressed -L -o plugins/vscode.typescript-language-features.vsix https://open-vsx.org/api/vscode/typescript-language-features/1.48.2/file/vscode.typescript-language-features-1.48.2.vsix
curl --compressed -L -o plugins/vscode.npm-1.49.0.vsix https://open-vsx.org/api/vscode/npm/1.49.0/file/vscode.npm-1.49.0.vsix
curl --compressed -L -o plugins/Orta.vscode-jest-4.0.0-alpha.1.vsix https://open-vsx.org/api/Orta/vscode-jest/4.0.0-alpha.1/file/Orta.vscode-jest-4.0.0-alpha.1.vsix
curl --compressed -L -o plugins/node-debug-1.35.3.vsix https://github.com/theia-ide/vscode-node-debug/releases/download/v1.35.3/node-debug-1.35.3.vsix
curl --compressed -L -o plugins/node-debug2-1.33.0.vsix https://github.com/theia-ide/vscode-node-debug2/releases/download/v1.33.0/node-debug2-1.33.0.vsix
curl --compressed -L -o plugins/msjsdiag.debugger-for-chrome-4.12.6.vsix https://open-vsx.org/api/msjsdiag/debugger-for-chrome/4.12.6/file/msjsdiag.debugger-for-chrome-4.12.6.vsix
curl --compressed -L -o plugins/firefox-devtools.vscode-firefox-debug-2.9.1.vsix https://open-vsx.org/api/firefox-devtools/vscode-firefox-debug/2.9.1/file/firefox-devtools.vscode-firefox-debug-2.9.1.vsix
curl --compressed -L -o plugins/vscode.html.vsix https://open-vsx.org/api/vscode/html/1.48.2/file/vscode.html-1.48.2.vsix
curl --compressed -L -o plugins/vscode.html-language-features.vsix https://open-vsx.org/api/vscode/html-language-features/1.48.2/file/vscode.html-language-features-1.48.2.vsix
curl --compressed -L -o plugins/vscode.css.vsix https://open-vsx.org/api/vscode/css/1.48.2/file/vscode.css-1.48.2.vsix
curl --compressed -L -o plugins/vscode.css-language-features.vsix https://open-vsx.org/api/vscode/css-language-features/1.48.2/file/vscode.css-language-features-1.48.2.vsix
curl --compressed -L -o plugins/jpoissonnier.vscode-styled-components.vsix https://open-vsx.org/api/jpoissonnier/vscode-styled-components/0.0.29/file/jpoissonnier.vscode-styled-components-0.0.29.vsix
curl --compressed -L -o plugins/vscode.emmet.vsix https://open-vsx.org/api/vscode/emmet/1.48.2/file/vscode.emmet-1.48.2.vsix
curl --compressed -L -o plugins/vscode-zipfs.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/arcanis/vsextensions/vscode-zipfs/2.0.0/vspackage
curl --compressed -L -o plugins/vscode.image-preview-1.49.0.vsix https://open-vsx.org/api/vscode/image-preview/1.49.0/file/vscode.image-preview-1.49.0.vsix
curl --compressed -L -o plugins/vscode.sql.vsix https://open-vsx.org/api/vscode/sql/1.48.2/file/vscode.sql-1.48.2.vsix
curl --compressed -L -o plugins/sqltools.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools/0.23.0/vspackage
curl --compressed -L -o plugins/sqltools-driver-pg.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-pg/0.2.0/vspackage
curl --compressed -L -o plugins/sqltools-driver-sqlite.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-sqlite/0.2.0/vspackage
curl --compressed -L -o plugins/sqltools-driver-mysql.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-mysql/0.2.0/vspackage
curl --compressed -L -o plugins/geequlim.godot-tools.vsix https://open-vsx.org/api/geequlim/godot-tools/1.0.1/file/geequlim.godot-tools-1.0.1.vsix

cd plugins
for z in *.vsix; do
    mkdir -p $z-extracted
    unzip $z -d $z-extracted
    rm $z
done
cd ..

if [ $ENABLE_CSHARP_SUPPORT = "1" ]; then
    rm /root/Repos/${IDE_NAME}/plugins/omnisharp_theia_plugin.vsix-extracted/.omnisharp/bin/mono
    ln -s $(which mono) /root/Repos/${IDE_NAME}/plugins/omnisharp_theia_plugin.vsix-extracted/.omnisharp/bin/mono
fi

mkdir -p ~/Workspaces/workspace-one

export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1
export NODE_OPTIONS="--max-old-space-size=8192"

yarn
yarn theia build

yarn global add wetty
yarn global add jest

x11vnc -storepasswd ${PASSWORD} /etc/vncsecret

fc-cache -f

openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
    -keyout /etc/nginx/server.key -out /etc/nginx/server.crt -subj "/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,DNS:*.webview.localhost,DNS:${DOMAIN},DNS:*.webview.${DOMAIN},IP:${IP}"

printf "${USERNAME}:$(openssl passwd -apr1 ${PASSWORD})\n" >/etc/nginx/.htpasswd

cat <<EOT >/etc/nginx/conf.d/default.conf
map \$http_upgrade \$connection_upgrade {
    default upgrade;
    '' close;
}

server {
    listen 8000 ssl;
    ssl_certificate      server.crt;
    ssl_certificate_key  server.key;
    server_name ${DOMAIN};

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
    server_name ${DOMAIN};

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
    server_name ${DOMAIN};

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
directory=/root/Repos/${IDE_NAME}
command=/usr/bin/yarn theia start ~/Workspaces/workspace-one --hostname 127.0.0.1 --port 3001 --plugins=local-dir:plugins
user=root
autorestart=true

[program:xvfb]
priority=300
command=/usr/bin/Xvfb :1 -screen 0 1400x1050x24 +iglx
user=root
autorestart=true

[program:x11vnc]
priority=400
command=x11vnc -rfbauth /etc/vncsecret -display :1 -xkb -noxrecord -noxfixes -noxdamage -wait 5 -shared
user=root
autorestart=true

[program:startxfce4]
priority=500
command=/usr/bin/startxfce4
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
