#!/bin/bash

## Configure your IDE here
if [ -z ${FULL_NAME+x} ]; then export FULL_NAME="Felicitas Pojtinger"; fi
if [ -z ${MOTD+x} ]; then export MOTD="Welcome to ${FULL_NAME}'s Alpine Linux Distribution!"; fi
if [ -z ${THEIA_IDE_DESCRIPTION+x} ]; then export THEIA_IDE_DESCRIPTION="${FULL_NAME}'s Theia IDE"; fi
if [ -z ${EMAIL+x} ]; then export EMAIL="felicitas@pojtinger.com"; fi
if [ -z ${GITHUB_USERNAME+x} ]; then export GITHUB_USERNAME="pojntfx"; fi # For your public SSH keys
if [ -z ${USERNAME+x} ]; then export USERNAME="pojntfx"; fi               # For accessing the services
if [ -z ${PASSWORD+x} ]; then export PASSWORD='mysvcpassword'; fi         # For accessing the services
if [ -z ${IDE_NAME+x} ]; then export IDE_NAME="pojde"; fi
if [ -z ${DOMAIN+x} ]; then export DOMAIN="pojntfx.dev.alphahorizon.io"; fi # Used for TLS SAN extensions; `localhost` is always included. Keep as is if you don't have a domain.
if [ -z ${IP+x} ]; then export IP="100.64.154.242"; fi                      # Used for TLS SAN extensions. Keep as is if you don't know the IP of the target machine.
if [ -z ${NAMESERVER+x} ]; then export NAMESERVER="8.8.8.8"; fi
if [ -z ${SCREEN_RESOLUTION+x} ]; then export SCREEN_RESOLUTION="1400x1050"; fi
if [ -z ${ENABLE_SECOPS_TOOLS+x} ]; then export ENABLE_SECOPS_TOOLS="0"; fi
if [ -z ${ENABLE_OS_SETUP+x} ]; then export ENABLE_OS_SETUP="1"; fi             # Set to "0" if you're not running this on a fresh system
if [ -z ${ENABLE_CSHARP_SUPPORT+x} ]; then export ENABLE_CSHARP_SUPPORT="0"; fi # Set to "1" if you want C# support; compiling Mono can take some time.
if [ -z ${ENABLE_NEOVIM_BUILD+x} ]; then export ENABLE_NEOVIM_BUILD="0"; fi     # Set to "1" if you want to have the latest neovim version from Git instead of the repository version
if [ -z ${INSTALL_DIR+x} ]; then export INSTALL_DIR="/opt/${IDE_NAME}"; fi
if [ -z ${WORKSPACE_DIR+x} ]; then export WORKSPACE_DIR="/root/${IDE_NAME}-workspace"; fi
## You shouldn't have to change anything below

mkdir -p /etc/pojde
echo "export FULL_NAME=\"${FULL_NAME}\"" >/etc/pojde/config.sh
echo "export MOTD=\"${MOTD}\"" >>/etc/pojde/config.sh
echo "export THEIA_IDE_DESCRIPTION=\"${THEIA_IDE_DESCRIPTION}\"" >>/etc/pojde/config.sh
echo "export EMAIL=\"${EMAIL}\"" >>/etc/pojde/config.sh
echo "export GITHUB_USERNAME=\"${GITHUB_USERNAME}\"" >>/etc/pojde/config.sh
echo "export USERNAME=\"${USERNAME}\"" >>/etc/pojde/config.sh
echo "export PASSWORD=\"${PASSWORD}\"" >>/etc/pojde/config.sh
echo "export DOMAIN=\"${DOMAIN}\"" >>/etc/pojde/config.sh
echo "export IP=\"${IP}\"" >>/etc/pojde/config.sh
echo "export NAMESERVER=\"${NAMESERVER}\"" >>/etc/pojde/config.sh
echo "export SCREEN_RESOLUTION=\"${SCREEN_RESOLUTION}\"" >>/etc/pojde/config.sh
echo "export ENABLE_OS_SETUP=\"${ENABLE_OS_SETUP}\"" >>/etc/pojde/config.sh
echo "export ENABLE_CSHARP_SUPPORT=\"${ENABLE_CSHARP_SUPPORT}\"" >>/etc/pojde/config.sh
echo "export ENABLE_NEOVIM_BUILD=\"${ENABLE_NEOVIM_BUILD}\"" >>/etc/pojde/config.sh
echo "export ENABLE_SECOPS_TOOLS=\"${ENABLE_SECOPS_TOOLS}\"" >>/etc/pojde/config.sh
echo "export IDE_NAME=\"${IDE_NAME}\"" >>/etc/pojde/config.sh
echo "export INSTALL_DIR=\"${INSTALL_DIR}\"" >>/etc/pojde/config.sh
echo "export WORKSPACE_DIR=\"${WORKSPACE_DIR}\"" >>/etc/pojde/config.sh

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

  rc-update add net.eth0 default
  rc-update add net.lo boot
fi

echo "nameserver $NAMESERVER" >/etc/resolv.conf

mkdir -m 700 -p /root/.ssh
wget -O - https://github.com/${GITHUB_USERNAME}.keys | tee /root/.ssh/authorized_keys
chmod 600 /root/.ssh/authorized_keys

sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/g' /etc/ssh/sshd_config

usermod -p '*' root

ln -sf /bin/bash /bin/sh

apk update
apk upgrade

export SYSTEM_ARCHITECTURE=$(uname -m)

apk add go

if [ $SYSTEM_ARCHITECTURE = "x86_64" ]; then
  curl -L -o /tmp/alpimager https://github.com/pojntfx/alpimager/releases/download/unstable-linux/alpimager
  install /tmp/alpimager /usr/local/bin
fi

mkdir -p /usr/lib/go/misc/wasm/
curl -L -o /usr/lib/go/misc/wasm/wasm_exec.js https://raw.githubusercontent.com/golang/go/master/misc/wasm/wasm_exec.js

curl https://sh.rustup.rs | bash -s -- -y

wget -q -O /etc/apk/keys/sgerrand.rsa.pub https://alpine-pkgs.sgerrand.com/sgerrand.rsa.pub
wget -O /tmp/glibc.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-2.32-r0.apk
wget -O /tmp/glibc-bin.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-bin-2.32-r0.apk
wget -O /tmp/glibc-dev.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-dev-2.32-r0.apk
wget -O /tmp/glibc-i18n.apk https://github.com/sgerrand/alpine-pkg-glibc/releases/download/2.32-r0/glibc-i18n-2.32-r0.apk
apk add /tmp/glibc.apk /tmp/glibc-bin.apk /tmp/glibc-dev.apk /tmp/glibc-i18n.apk

cat <<EOT >/etc/profile.d/main.sh
export JAVA_HOME="/usr/lib/jvm/java-14-openjdk"
export PATH="\$JAVA_HOME/bin:\$PATH"
export PATH="/root/go/bin:\$PATH"
export DOTNET_ROOT="/usr/share/dotnet"
export PATH="\$DOTNET_ROOT:\$PATH"
export LIBRARY_PATH="/lib:/usr/lib"
export PATH="/root/.cargo/bin:\$PATH"
export CGO_CFLAGS="-g -O2 -Wno-return-local-addr"
export PATH="\$PATH:/root/.arkade/bin/"
export PATH="/usr/local/bin/:\$PATH"
export PATH="/root/.local/bin/:\$PATH"

alias burp="java -jar /opt/burp/burp.jar"
alias zap="java -jar /opt/zap/ZAP_2.9.0/zap-2.9.0.jar"

ulimit -n 65000
EOT
chmod +x /etc/profile.d/main.sh

cat <<EOT >/root/.bashrc
HISTSIZE= 
HISTFILESIZE=

source /etc/profile
EOT
chmod +x /root/.bashrc

source /root/.bashrc

git config --global user.name "${FULL_NAME}"
git config --global user.email "${EMAIL}"
git config --global pull.rebase false
git config --global init.defaultBranch main

rm -rf ${INSTALL_DIR}
mkdir -p ${INSTALL_DIR}

if [ $ENABLE_CSHARP_SUPPORT = "1" ]; then
  rm -rf ${INSTALL_DIR}/mono.git
  mkdir -p ${INSTALL_DIR}/mono.git
  git clone https://github.com/mono/mono.git ${INSTALL_DIR}/mono.git
  cd ${INSTALL_DIR}/mono.git
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

rm -rf ${INSTALL_DIR}/lldb-mi
mkdir -p ${INSTALL_DIR}/lldb-mi
git clone https://github.com/lldb-tools/lldb-mi.git ${INSTALL_DIR}/lldb-mi
cd ${INSTALL_DIR}/lldb-mi
cmake .
cmake --build . --target install

if [ $ENABLE_NEOVIM_BUILD = "1" ]; then
  rm -rf ${INSTALL_DIR}/neovim
  mkdir -p ${INSTALL_DIR}/neovim
  git clone https://github.com/neovim/neovim ${INSTALL_DIR}/neovim
  cd ${INSTALL_DIR}/neovim
  make
  make install

  ln -sf /usr/local/bin/nvim /usr/bin/nvim
else
  apk add neovim

  ln -sf /usr/bin/nvim /usr/local/bin/nvim
fi

ln -sf /usr/local/bin/nvim /usr/bin/vi
ln -sf /usr/local/bin/nvim /usr/bin/vim

echo fs.inotify.max_user_watches=524288 | tee /etc/sysctl.d/inotify && sysctl -p

gvfs_pkgs=$(apk search gvfs -q | grep -v '\-dev' | grep -v '\-lang' | grep -v '\-doc')
apk add $gvfs_pkgs
ttfs=$(apk search -q ttf- | grep -v '\-doc')
apk add $ttfs

apk del ttf-linux-libertine
apk del ttf-google-opensans

mkdir -p ~/Desktop

echo "CHROMIUM_FLAGS='--no-sandbox --test-type'" >/etc/chromium/chromium.conf

cat <<EOT >~/Desktop/Chromium.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Chromium
Comment=Access the Internet
Exec=chromium-browser %U
Icon=chromium
Path=
Terminal=false
StartupNotify=false
EOT

cat <<EOT >~/Desktop/Firefox.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Firefox
Exec=firefox %U
Icon=firefox
Path=
Terminal=false
StartupNotify=false
EOT

cat <<EOT >~/Desktop/Web.desktop
[Desktop Entry]
Version=1.0
Type=Application
Name=Web
Exec=epiphany %U
Icon=org.gnome.Epiphany
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

chmod +x ~/Desktop/*.desktop

if [ $SYSTEM_ARCHITECTURE = "x86_64" ]; then
  curl -L -o /tmp/skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-amd64
else
  curl -L -o /tmp/skaffold https://storage.googleapis.com/skaffold/releases/latest/skaffold-linux-arm64
fi
install /tmp/skaffold /usr/local/bin

if [ $SYSTEM_ARCHITECTURE = "x86_64" ]; then
  curl -sLS https://dl.get-arkade.dev | sh

  arkade get kubectl
  arkade get k9s
  arkade get helm
  arkade get k3d
  arkade get k3sup

  ln -s ~/.arkade/bin/kubectl /usr/local/bin/kubectl
  ln -s ~/.arkade/bin/helm /usr/local/bin/helm
else
  apk add curl k9s helm
fi

curl https://cli-assets.heroku.com/install.sh | sh

go get webwormhole.io/cmd/ww

if [ $SYSTEM_ARCHITECTURE = "x86_64" ]; then
  curl -L -o /tmp/kite-installer https://linux.kite.com/dls/linux/current
  chmod +x /tmp/kite-installer
  /tmp/kite-installer --install

  cat <<EOT >/etc/init.d/kited
#!/sbin/openrc-run                                                                                                                                                                                                    

DOCKER_HOST=""

name=\$RC_SVCNAME
command="/root/.local/share/kite/kited"
pidfile="/run/\$RC_SVCNAME.pid"
command_background="yes"
EOT
  chmod +x /etc/init.d/kited
fi

pip install -U pylint --user
pip install -U autopep8 --user
pip install -U speedtest-cli --user

rm -rf /opt/wasmtime
mkdir -p /opt/wasmtime
if [ $SYSTEM_ARCHITECTURE = "x86_64" ]; then
  curl -L -o /tmp/wasmtime.tar.xz https://github.com/bytecodealliance/wasmtime/releases/download/v0.21.0/wasmtime-v0.21.0-x86_64-linux.tar.xz
else
  curl -L -o /tmp/wasmtime.tar.xz https://github.com/bytecodealliance/wasmtime/releases/download/v0.21.0/wasmtime-v0.21.0-aarch64-linux.tar.xz
fi
tar xf /tmp/wasmtime.tar.xz -C /opt/wasmtime
ln -sf /opt/wasmtime/*/wasmtime /usr/bin/wasmtime

if [ $ENABLE_SECOPS_TOOLS = "1" ]; then
  rm -rf /opt/burp
  mkdir -p /opt/burp
  curl -o /opt/burp/burp.jar 'https://portswigger.net/burp/releases/download?product=community&version=2020.9.2&type=Jar'
  go get -u github.com/ffuf/ffuf

  pip install sqlmap

  rm -rf /usr/share/metasploit-framework
  git clone https://github.com/rapid7/metasploit-framework.git /usr/share/metasploit-framework
  cd /usr/share/metasploit-framework
  bundle update --bundler
  bundle install

  rm -rf /opt/hydra
  git clone https://github.com/vanhauser-thc/thc-hydra.git /opt/hydra
  cd /opt/hydra
  ./configure
  make
  make install

  gem install wpscan

  rm -rf /opt/zap
  mkdir -p /opt/zap
  curl -L -o /tmp/zap.tar.gz https://github.com/zaproxy/zaproxy/releases/download/v2.9.0/ZAP_2.9.0_Linux.tar.gz
  tar xvzf /tmp/zap.tar.gz -C /opt/zap
fi

npm i -g --unsafe-perm jest @vue/cli localtunnel wscat node-plantuml webtorrent-hybrid serve spotify-dl

sed -i /etc/passwd -e 's/\/bin\/ash/\/bin\/bash/g'

if grep docker /proc/1/cgroup -qa; then
  apk add docker-cli
else
  apk add docker
fi # dind

curl -fsSL https://code-server.dev/install.sh | sh
ln -sf /root/.local/bin/code-server /usr/bin/code-server

for file in /root/.local/lib/code-server-*; do ln -sf /usr/bin/node $file/lib/node; done

rm -rf ~/.config/code-server
mkdir -p ~/.config/code-server
rm -rf ~/.local/share/code-server
mkdir -p ~/.local/share/code-server/User

rm -rf ~/.theia
mkdir -p ~/.theia

cat <<EOT >~/.theia/keymaps.json
[
  {
    "command": "-editor.action.marker.nextInFiles",
    "keybinding": "f8",
    "when": "editorFocus && !editorReadonly",
    "resolved": [
      {
        "key": {
          "code": "F8",
          "keyCode": 119,
          "easyString": "f8"
        },
        "ctrl": false,
        "shift": false,
        "alt": false,
        "meta": false
      }
    ],
    "scope": 1,
    "key": "f8"
  },
  {
    "command": "editor.action.marker.nextInFiles",
    "keybinding": "alt+p",
    "when": "editorFocus && !editorReadonly",
    "resolved": [
      {
        "key": {
          "code": "KeyP",
          "keyCode": 80,
          "easyString": "p"
        },
        "ctrl": false,
        "shift": false,
        "alt": true,
        "meta": false
      }
    ],
    "scope": 1,
    "key": "alt+p"
  },
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
    "scope": 1,
    "key": "f2"
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
    "scope": 1,
    "key": "alt+r"
  },
  {
    "command": "editor.action.rename",
    "keybinding": "alt+r",
    "when": "editorHasRenameProvider && editorTextFocus && !editorReadonly",
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
    "scope": 1,
    "key": "alt+r"
  },
  {
    "command": "-editor.action.rename",
    "keybinding": "f2",
    "when": "editorHasRenameProvider && editorTextFocus && !editorReadonly",
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
    "scope": 1,
    "key": "f2"
  },
  {
    "command": "editor.action.goToReferences",
    "keybinding": "alt+i",
    "when": "editorHasReferenceProvider && editorTextFocus && !inReferenceSearchEditor && !isInEmbeddedEditor",
    "key": "alt+i"
  },
  {
    "command": "-editor.action.goToReferences",
    "keybinding": "shift+f12",
    "when": "editorHasReferenceProvider && editorTextFocus && !inReferenceSearchEditor && !isInEmbeddedEditor",
    "key": "shift+f12"
  },
  {
    "key": "alt+w",
    "command": "workbench.action.closeActiveEditor"
  },
  {
    "key": "shift+alt+p",
    "command": "workbench.action.showCommands"
  },
  {
    "key": "f1",
    "command": "-workbench.action.showCommands"
  }
]
EOT
cp ~/.theia/keymaps.json ~/.local/share/code-server/User/keybindings.json
cp ~/.theia/keymaps.json ~/.local/share/code-server/keybindings.json

cat <<EOT >~/.local/share/code-server/User/settings.json
{
  "workbench.iconTheme": "vs-seti",
  "workbench.colorTheme": "GitHub Dark",
  "go.autocompleteUnimportedPackages": true,
  "go.useLanguageServer": true,
  "vim.debug.silent": true,
  "sqltools.useNodeRuntime": true,
  "files.enableTrash": false,
  "editor.autoSave": "on",
  "cmake.configureOnOpen": true,
  "cmake.debugConfig": {
    "type": "lldb-mi",
    "request": "launch",
    "target": "\${command:cmake.launchTargetPath}",
    "args": [],
    "cwd": "\${workspaceFolder}"
  },
  "ruby.useLanguageServer": true,
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
  "editor.smoothScrolling": true,
  "kite.showWelcomeNotificationOnStartup": false,
  "clangd.path": "/usr/bin/clangd",
  "git.autofetch": true,
  "emmet.triggerExpansionOnTab": true,
  "clipboard-manager.snippet.enabled": false,
  "jest.autoEnable": false,
  "vscode-neovim.neovimExecutablePaths.linux": "/usr/bin/vi",
  "[jsonc]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[yaml]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[dockerfile]": {
    "editor.defaultFormatter": "foxundermoon.shell-format"
  },
  "[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
EOT

mkdir -p ${INSTALL_DIR}/theia
cd ${INSTALL_DIR}/theia

cat <<EOT >package.json
{
  "name": "@${USERNAME}/${IDE_NAME}",
  "version": "0.0.1-alpha1",
  "description": "${THEIA_IDE_DESCRIPTION}",
  "main": "index.js",
  "scripts": {
    "test": "echo \"Error: no test specified\" && exit 1"
  },
  "author": "${FULL_NAME} <${EMAIL}>",
  "license": "AGPL-3.0",
  "theia": {
    "frontend": {
      "config": {
        "applicationName": "${THEIA_IDE_DESCRIPTION}",
        "preferences": $(cat ~/.local/share/code-server/User/settings.json)
      }
    }
  },
  "dependencies": {
    "@theia/callhierarchy": "latest",
    "@theia/console": "latest",
    "@theia/core": "latest",
    "@theia/debug": "latest",
    "@theia/editor": "latest",
    "@theia/editor-preview": "latest",
    "@theia/file-search": "latest",
    "@theia/filesystem": "latest",
    "@theia/getting-started": "latest",
    "@theia/git": "latest",
    "@theia/keymaps": "latest",
    "@theia/markers": "latest",
    "@theia/messages": "latest",
    "@theia/metrics": "latest",
    "@theia/mini-browser": "latest",
    "@theia/monaco": "latest",
    "@theia/navigator": "latest",
    "@theia/outline-view": "latest",
    "@theia/output": "latest",
    "@theia/plugin": "latest",
    "@theia/plugin-ext": "latest",
    "@theia/plugin-ext-vscode": "latest",
    "@theia/preferences": "latest",
    "@theia/preview": "latest",
    "@theia/process": "latest",
    "@theia/scm": "latest",
    "@theia/search-in-workspace": "latest",
    "@theia/task": "latest",
    "@theia/terminal": "latest",
    "@theia/typehierarchy": "latest",
    "@theia/userstorage": "latest",
    "@theia/variable-resolver": "latest",
    "@theia/vsx-registry": "latest",
    "@theia/workspace": "latest",
    "vscode-jsonrpc": "5.0.1"
  },
  "devDependencies": {
    "@theia/cli": "latest"
  }
}
EOT

rm -rf plugins
rm -rf ~/.local/share/code-server/extensions/

mkdir -p plugins

# Extensions from Open-VSX (preferred method)
curl 'https://open-vsx.org/api/eamodio/gitlens' | jq '.files.download' | xargs curl --compressed -L -o plugins/gitlens.vsix
curl 'https://open-vsx.org/api/mhutchie/git-graph' | jq '.files.download' | xargs curl --compressed -L -o plugins/git-graph.vsix
curl 'https://open-vsx.org/api/esbenp/prettier-vscode' | jq '.files.download' | xargs curl --compressed -L -o plugins/prettier-vscode.vsix
# curl 'https://open-vsx.org/api/vscodevim/vim/1.16.0' | jq '.files.download' | xargs curl --compressed -L -o plugins/vim.vsix # Locked to work with code-server # Currently disabled & replace with vscode-neovim until code-server rebases to VSCode 1.52
curl 'https://open-vsx.org/api/asvetliakov/vscode-neovim' | jq '.files.download' | xargs curl --compressed -L -o plugins/nvim.vsix
curl 'https://open-vsx.org/api/vscode/markdown' | jq '.files.download' | xargs curl --compressed -L -o plugins/markdown.vsix
curl 'https://open-vsx.org/api/vscode/markdown-language-features' | jq '.files.download' | xargs curl --compressed -L -o plugins/markdown-language-features.vsix
curl 'https://open-vsx.org/api/vscode/yaml' | jq '.files.download' | xargs curl --compressed -L -o plugins/yaml.vsix
curl 'https://open-vsx.org/api/redhat/vscode-yaml' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-yaml.vsix
curl 'https://open-vsx.org/api/bungcip/better-toml' | jq '.files.download' | xargs curl --compressed -L -o plugins/better-toml.vsix
curl 'https://open-vsx.org/api/vscode/json' | jq '.files.download' | xargs curl --compressed -L -o plugins/json.vsix
curl 'https://open-vsx.org/api/vscode/json-language-features' | jq '.files.download' | xargs curl --compressed -L -o plugins/json-language-features.vsix
curl 'https://open-vsx.org/api/zxh404/vscode-proto3' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-proto3.vsix
curl 'https://open-vsx.org/api/Prisma/vscode-graphql' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-graphql.vsix
curl 'https://open-vsx.org/api/vscode/xml' | jq '.files.download' | xargs curl --compressed -L -o plugins/xml.vsix
curl 'https://open-vsx.org/api/redhat/vscode-xml' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-xml.vsix
curl 'https://open-vsx.org/api/hediet/vscode-drawio' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-drawio.vsix
curl 'https://open-vsx.org/api/vscode/image-preview' | jq '.files.download' | xargs curl --compressed -L -o plugins/image-preview.vsix
curl 'https://open-vsx.org/api/vscode/shellscript' | jq '.files.download' | xargs curl --compressed -L -o plugins/shellscript.vsix
curl 'https://open-vsx.org/api/foxundermoon/shell-format' | jq '.files.download' | xargs curl --compressed -L -o plugins/shell-format.vsix
curl 'https://open-vsx.org/api/vscode/cpp' | jq '.files.download' | xargs curl --compressed -L -o plugins/cpp.vsix
curl 'https://open-vsx.org/api/webfreak/debug' | jq '.files.download' | xargs curl --compressed -L -o plugins/webfreak-debug.vsix
curl 'https://open-vsx.org/api/llvm-vs-code-extensions/vscode-clangd' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-clangd.vsix
curl 'https://open-vsx.org/api/twxs/cmake' | jq '.files.download' | xargs curl --compressed -L -o plugins/cmake.vsix
curl 'https://open-vsx.org/api/vscode/make' | jq '.files.download' | xargs curl --compressed -L -o plugins/make.vsix
curl 'https://open-vsx.org/api/matepek/vscode-catch2-test-adapter' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-catch2-test-adapter.vsix
curl 'https://open-vsx.org/api/vscode/rust' | jq '.files.download' | xargs curl --compressed -L -o plugins/rust.vsix
curl 'https://open-vsx.org/api/matklad/rust-analyzer' | jq '.files.download' | xargs curl --compressed -L -o plugins/rust-analyzer.vsix
curl 'https://open-vsx.org/api/serayuzgur/crates' | jq '.files.download' | xargs curl --compressed -L -o plugins/crates.vsix
curl 'https://open-vsx.org/api/vscode/go' | jq '.files.download' | xargs curl --compressed -L -o plugins/go.vsix
curl 'https://open-vsx.org/api/golang/Go' | jq '.files.download' | xargs curl --compressed -L -o plugins/golang-Go.vsix
curl 'https://open-vsx.org/api/vscode/java' | jq '.files.download' | xargs curl --compressed -L -o plugins/java.vsix
curl 'https://open-vsx.org/api/redhat/java' | jq '.files.download' | xargs curl --compressed -L -o plugins/redhat-java.vsix
curl 'https://open-vsx.org/api/vscjava/vscode-java-debug' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-java-debug.vsix
curl 'https://open-vsx.org/api/vscjava/vscode-java-test' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-java-test.vsix
curl 'https://open-vsx.org/api/vscjava/vscode-maven' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-maven.vsix
curl 'https://open-vsx.org/api/richardwillis/vscode-gradle' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-gradle.vsix
curl 'https://open-vsx.org/api/vscjava/vscode-java-dependency' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-java-dependency.vsix
curl 'https://open-vsx.org/api/vscode/python' | jq '.files.download' | xargs curl --compressed -L -o plugins/python.vsix
curl 'https://open-vsx.org/api/ms-python/python' | jq '.files.download' | xargs curl --compressed -L -o plugins/ms-python.vsix
if [ $SYSTEM_ARCHITECTURE = "x86_64" ]; then
  curl 'https://open-vsx.org/api/kiteco/kite' | jq '.files.download' | xargs curl --compressed -L -o plugins/kite.vsix
fi
curl 'https://open-vsx.org/api/vscode/ruby' | jq '.files.download' | xargs curl --compressed -L -o plugins/ruby.vsix
curl 'https://open-vsx.org/api/rebornix/ruby' | jq '.files.download' | xargs curl --compressed -L -o plugins/rebornix-ruby.vsix
curl 'https://open-vsx.org/api/vscode/javascript' | jq '.files.download' | xargs curl --compressed -L -o plugins/javascript.vsix
curl 'https://open-vsx.org/api/vscode/typescript' | jq '.files.download' | xargs curl --compressed -L -o plugins/typescript.vsix
curl 'https://open-vsx.org/api/vscode/typescript-language-features' | jq '.files.download' | xargs curl --compressed -L -o plugins/typescript-language-features.vsix
curl 'https://open-vsx.org/api/vscode/npm' | jq '.files.download' | xargs curl --compressed -L -o plugins/npm.vsix
curl 'https://open-vsx.org/api/Orta/vscode-jest' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-jest.vsix
curl 'https://open-vsx.org/api/ms-vscode/node-debug' | jq '.files.download' | xargs curl --compressed -L -o plugins/node-debug.vsix
curl 'https://open-vsx.org/api/ms-vscode/node-debug2' | jq '.files.download' | xargs curl --compressed -L -o plugins/node-debug2.vsix
curl 'https://open-vsx.org/api/ms-vscode/js-debug' | jq '.files.download' | xargs curl --compressed -L -o plugins/js-debug.vsix
curl 'https://open-vsx.org/api/msjsdiag/debugger-for-chrome' | jq '.files.download' | xargs curl --compressed -L -o plugins/debugger-for-chrome.vsix
curl 'https://open-vsx.org/api/firefox-devtools/vscode-firefox-debug' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-firefox-debug.vsix
curl 'https://open-vsx.org/api/vscode/html' | jq '.files.download' | xargs curl --compressed -L -o plugins/html.vsix
curl 'https://open-vsx.org/api/vscode/html-language-features' | jq '.files.download' | xargs curl --compressed -L -o plugins/html-language-features.vsix
curl 'https://open-vsx.org/api/vscode/css' | jq '.files.download' | xargs curl --compressed -L -o plugins/css.vsix
curl 'https://open-vsx.org/api/vscode/css-language-features' | jq '.files.download' | xargs curl --compressed -L -o plugins/css-language-features.vsix
curl 'https://open-vsx.org/api/jpoissonnier/vscode-styled-components' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-styled-components.vsix
curl 'https://open-vsx.org/api/octref/vetur' | jq '.files.download' | xargs curl --compressed -L -o plugins/vetur.vsix
curl 'https://open-vsx.org/api/vscode/emmet' | jq '.files.download' | xargs curl --compressed -L -o plugins/emmet.vsix
curl 'https://open-vsx.org/api/vscode/sql' | jq '.files.download' | xargs curl --compressed -L -o plugins/sql.vsix
curl 'https://open-vsx.org/api/geequlim/godot-tools' | jq '.files.download' | xargs curl --compressed -L -o plugins/godot-tools.vsix
curl 'https://open-vsx.org/api/vscode/docker' | jq '.files.download' | xargs curl --compressed -L -o plugins/docker.vsix
curl 'https://open-vsx.org/api/ms-azuretools/vscode-docker' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-docker.vsix
curl 'https://open-vsx.org/api/ms-kubernetes-tools/vscode-kubernetes-tools' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-kubernetes-tools.vsix
curl 'https://open-vsx.org/api/valentjn/vscode-ltex' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-ltex.vsix
curl 'https://open-vsx.org/api/James-Yu/latex-workshop' | jq '.files.download' | xargs curl --compressed -L -o plugins/latex-workshop.vsix
curl 'https://open-vsx.org/api/alefragnani/project-manager' | jq '.files.download' | xargs curl --compressed -L -o plugins/project-manager.vsix
curl 'https://open-vsx.org/api/EdgardMessias/clipboard-manager' | jq '.files.download' | xargs curl --compressed -L -o plugins/clipboard-manager.vsix
curl 'https://open-vsx.org/api/jock/svg' | jq '.files.download' | xargs curl --compressed -L -o plugins/svg.vsix
curl 'https://open-vsx.org/api/jebbs/plantuml' | jq '.files.download' | xargs curl --compressed -L -o plugins/plantuml.vsix
curl 'https://open-vsx.org/api/bradlc/vscode-tailwindcss' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-tailwindcss.vsix
curl 'https://open-vsx.org/api/42Crunch/vscode-openapi' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-openapi.vsix
curl 'https://open-vsx.org/api/foam/foam-vscode' | jq '.files.download' | xargs curl --compressed -L -o plugins/foam-vscode.vsix
curl 'https://open-vsx.org/api/kortina/vscode-markdown-notes' | jq '.files.download' | xargs curl --compressed -L -o plugins/vscode-markdown-notes.vsix
curl 'https://open-vsx.org/api/tchayen/markdown-links' | jq '.files.download' | xargs curl --compressed -L -o plugins/markdown-links.vsix
curl 'https://open-vsx.org/api/yzhang/markdown-all-in-one' | jq '.files.download' | xargs curl --compressed -L -o plugins/markdown-all-in-one.vsix

if [ $ENABLE_CSHARP_SUPPORT = "1" ]; then
  curl 'https://open-vsx.org/api/vscode/csharp' | jq '.files.download' | xargs curl --compressed -L -o plugins/csharp.vsix
  curl 'https://open-vsx.org/api/k--kato/docomment' | jq '.files.download' | xargs curl --compressed -L -o plugins/docomment.vsix
fi

# Extensions from GitHub (second best option)
curl --compressed -L -o plugins/omnisharp_theia_plugin.vsix https://github.com/redhat-developer/omnisharp-theia-plugin/releases/download/v0.0.6/omnisharp_theia_plugin.theia
curl --compressed -L -o plugins/cmake-format.vsix https://github.com/cheshirekow/cmake_format/releases/download/v0.6.13/cmake-format-0.6.13.vsix
curl --compressed -L -o plugins/cmake-format.vsix https://github.com/cheshirekow/cmake_format/releases/download/v0.6.13/cmake-format-0.6.13.vsix
curl --compressed -L -o plugins/vscode-tinygo.vsix https://github.com/tinygo-org/vscode-tinygo/releases/download/0.2.0/vscode-tinygo-0.2.0.vsix

# Extensions from code-server marketplace (third best option)
code-server --force --install-extension 'naco-siren.gradle-language'
code-server --force --install-extension 'dsznajder.es7-react-js-snippets'
code-server --force --install-extension 'mtxr.sqltools'
code-server --force --install-extension 'tinkertrain.theme-panda'
code-server --force --install-extension 'miguelsolorio.min-theme'
code-server --force --install-extension 'akamud.vscode-theme-onelight'
code-server --force --install-extension 'akamud.vscode-theme-onedark'
code-server --force --install-extension 'ahmadawais.shades-of-purple'
code-server --force --install-extension 'dracula-theme.theme-dracula'
code-server --force --install-extension 'jolaleye.horizon-theme-vscode'
code-server --force --install-extension 'taniarascia.new-moon-vscode'
code-server --force --install-extension 'github.github-vscode-theme'
code-server --force --install-extension 'equinusocio.vsc-material-theme'
code-server --force --install-extension 'equinusocio.vsc-material-theme-icons'
code-server --force --install-extension 'ms-vscode.mono-debug'
code-server --force --install-extension 'ms-vscode.cmake-tools'
code-server --force --install-extension 'tyriar.lorem-ipsum'
code-server --force --install-extension 'tomoki1207.pdf'
code-server --force --install-extension 'cmstead.jsrefactor'

# Extensions from MS marketplace (worst option; rate limited)
curl --compressed -L -o plugins/vscode-javadoc-tools.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/madhavd1/vsextensions/javadoc-tools/1.4.0/vspackage
curl --compressed -L -o plugins/zig-snippets.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/lorenzopirro/vsextensions/zig-snippets/1.3.0/vspackage
curl --compressed -L -o plugins/zig.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/tiehuis/vsextensions/zig/0.2.5/vspackage
curl --compressed -L -o plugins/vscode-zipfs.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/arcanis/vsextensions/vscode-zipfs/2.2.2/vspackage
curl --compressed -L -o plugins/sqltools-driver-mysql.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-mysql/0.2.0/vspackage
curl --compressed -L -o plugins/sqltools-driver-sqlite.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-sqlite/0.2.0/vspackage
curl --compressed -L -o plugins/sqltools-driver-pg.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-pg/0.2.0/vspackage
curl --compressed -L -o plugins/web-accessibility.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/MaxvanderSchee/vsextensions/web-accessibility/0.2.83/vspackage

cd plugins
for z in *.vsix; do
  code-server --install-extension $z
  mkdir -p $z-extracted
  unzip $z -d $z-extracted
  rm $z
done
cd ..

for extension in ~/.local/share/code-server/extensions/*; do
  cp -r $extension ${INSTALL_DIR}/theia/plugins
done

if [ $ENABLE_CSHARP_SUPPORT = "1" ]; then
  rm ${INSTALL_DIR}/theia/plugins/omnisharp_theia_plugin.vsix-extracted/.omnisharp/bin/mono
  ln -s $(which mono) ${INSTALL_DIR}/theia/plugins/omnisharp_theia_plugin.vsix-extracted/.omnisharp/bin/mono
fi

mkdir -p ${WORKSPACE_DIR}

export PUPPETEER_SKIP_CHROMIUM_DOWNLOAD=1
export NODE_OPTIONS="--max-old-space-size=8192"

yarn --network-timeout 1000000
yarn theia build

x11vnc -storepasswd ${PASSWORD} /etc/vncsecret

rm -rf /opt/pojde/code-server
mkdir -p /opt/pojde/code-server
cat <<EOT >/opt/pojde/code-server/config.yaml
bind-addr: 0.0.0.0:8002
auth: password
password: ${PASSWORD}
cert: /etc/nginx/server.crt
cert-key: /etc/nginx/server.key
EOT

fc-cache -f

if [ "$(cat /etc/nginx/domain-ip)" != "${DOMAIN}-${IP}" ]; then
  openssl genrsa -out /etc/nginx/ca.key 2048
  openssl req -x509 -new -nodes -key /etc/nginx/ca.key -sha256 -days 365 -out /etc/nginx/ca.pem -subj "/CN=${DOMAIN}"

  openssl genrsa -out /etc/nginx/server.key 2048
  openssl req -new -key /etc/nginx/server.key -out /etc/nginx/server.csr -subj "/CN=${DOMAIN}"

  openssl x509 -req -in /etc/nginx/server.csr -CA /etc/nginx/ca.pem -CAkey /etc/nginx/ca.key -CAcreateserial -out /etc/nginx/server.crt -days 365 -sha256 -extfile <(echo "authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = ${IP}
DNS.1 = localhost
DNS.2 = *.webview.localhost
DNS.3 = localhost.localdomain
DNS.4 = *.webview.localhost.localdomain
DNS.5 = local.local
DNS.6 = *.webview.local.local
DNS.7 = ${DOMAIN}
DNS.8 = *.webview.${DOMAIN}")
fi

printf "${DOMAIN}-${IP}" >/etc/nginx/domain-ip

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
        proxy_pass http://localhost:2999;
        proxy_set_header Host \$host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
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
    listen 8003 ssl;
    ssl_certificate      server.crt;
    ssl_certificate_key  server.key;
    server_name ${DOMAIN};

    location / {
        proxy_pass http://localhost:3003;
        proxy_set_header Host \$host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection \$connection_upgrade;
        proxy_set_header X-Real-IP \$remote_addr;
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;
    }
}
EOT

DOCKER_HOST_OVERWRITE=""
if grep docker /proc/1/cgroup -qa; then DOCKER_HOST_OVERWRITE="DOCKER_HOST=\"unix:///opt/pojde/docker.sock\","; fi # dind
SUPERVISORD_ENV_VARIABLES="environment=HOME=/root,USER=root,${DOCKER_HOST_OVERWRITE}DISPLAY=\":1\""

cat <<EOT >/etc/supervisord.conf
[supervisord]
nodaemon=true

[program:ttyd]
priority=100
${SUPERVISORD_ENV_VARIABLES}
command=/usr/bin/ttyd -i lo --port 2999 -c ${USERNAME}:${PASSWORD} -a /bin/bash -l
user=root
autorestart=true

[program:theia]
priority=200
directory=${INSTALL_DIR}/theia
${SUPERVISORD_ENV_VARIABLES}
command=/usr/bin/yarn theia start ${WORKSPACE_DIR} --hostname 127.0.0.1 --port 3001 --plugins=local-dir:plugins --vscode-api-version=1.50.1
user=root
autorestart=true

[program:code-server]
priority=300
${SUPERVISORD_ENV_VARIABLES}
command=/usr/bin/code-server --config /opt/pojde/code-server/config.yaml
user=root
autorestart=true

[program:xvfb]
priority=400
${SUPERVISORD_ENV_VARIABLES}
command=/usr/bin/Xvfb :1 -screen 0 ${SCREEN_RESOLUTION}x24 +iglx
user=root
autorestart=true

[program:x11vnc]
priority=500
${SUPERVISORD_ENV_VARIABLES}
command=x11vnc -rfbauth /etc/vncsecret -display :1 -xkb -noxrecord -noxfixes -noxdamage -wait 5 -shared -repeat
user=root
autorestart=true

[program:startxfce4]
priority=600
${SUPERVISORD_ENV_VARIABLES}
command=/usr/bin/startxfce4
user=root
autorestart=true

[program:novnc]
priority=700
${SUPERVISORD_ENV_VARIABLES}
command=/usr/bin/novnc_server --vnc localhost:5900 --listen 3003
user=root
autorestart=true

[program:nginx]
priority=800
${SUPERVISORD_ENV_VARIABLES}
command=/bin/sh -c "mkdir -p /run/nginx && /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf"
user=root
autorestart=true
EOT

echo "sh -c \"\$(curl -sSL https://raw.githubusercontent.com/pojntfx/pojde/master/update-pojde)\"" >/usr/local/bin/update-pojde
chmod +x /usr/local/bin/update-pojde

echo "Almost done! In order to continue, please click the following link:"

ww send /etc/nginx/ca.pem

echo "Setup completed! Please continue at https://github.com/pojntfx/pojde#usage. You might loose your connection if you're connected via SSH or are using one of the services. In that case, please reconnect/reload."

DOCKER_SERVICES_NAMES="docker udev"
if grep docker /proc/1/cgroup -qa; then DOCKER_SERVICES_NAMES=""; fi # dind
services="dbus fuse $DOCKER_SERVICES_NAMES libvirtd sshd supervisord"
if [ $SYSTEM_ARCHITECTURE = "x86_64" ]; then
  services="kited dbus fuse $DOCKER_SERVICES_NAMES libvirtd sshd supervisord"
fi
for service in $services; do
  nohup /bin/sh -c "rc-update add $service default; rc-service $service restart" >/dev/null 2>&1 &
done
