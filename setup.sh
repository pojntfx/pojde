#!/bin/bash

# Read user configuration from env
function read_user_configuration() {
  if [ -z ${FULL_NAME+x} ]; then export FULL_NAME="Felix Pojtinger"; fi
  if [ -z ${MOTD+x} ]; then export MOTD="Welcome to ${FULL_NAME}'s Alpine Linux Distribution!"; fi
  if [ -z ${THEIA_IDE_DESCRIPTION+x} ]; then export THEIA_IDE_DESCRIPTION="${FULL_NAME}'s Theia IDE"; fi
  if [ -z ${EMAIL+x} ]; then export EMAIL="felix@pojtinger.com"; fi
  if [ -z ${GITHUB_USERNAME+x} ]; then export GITHUB_USERNAME="pojntfx"; fi # For your public SSH keys
  if [ -z ${USERNAME+x} ]; then export USERNAME="pojntfx"; fi               # For accessing the services
  if [ -z ${PASSWORD+x} ]; then export PASSWORD='mysvcpassword'; fi         # For accessing the services
  if [ -z ${IDE_NAME+x} ]; then export IDE_NAME="pojde"; fi
  if [ -z ${DOMAIN+x} ]; then export DOMAIN="pojntfx.dev.alphahorizon.io"; fi # Used for TLS SAN extensions; `localhost` is always included. Keep as is if you don't have a domain.
  if [ -z ${IP+x} ]; then export IP="100.64.154.242"; fi                      # Used for TLS SAN extensions. Keep as is if you don't know the IP of the target machine.
  if [ -z ${NAMESERVER+x} ]; then export NAMESERVER="8.8.8.8"; fi
  if [ -z ${SCREEN_RESOLUTION+x} ]; then export SCREEN_RESOLUTION="1400x1050"; fi
  if [ -z ${ENABLE_SECOPS_TOOLS+x} ]; then export ENABLE_SECOPS_TOOLS="0"; fi
  if [ -z ${ENABLE_OS_SETUP+x} ]; then export ENABLE_OS_SETUP="1"; fi         # Set to "0" if you're not running this on a fresh system.
  if [ -z ${ENABLE_MONO_BUILD+x} ]; then export ENABLE_MONO_BUILD="0"; fi     # Set to "1" if you want to build Mono from source.
  if [ -z ${ENABLE_NEOVIM_BUILD+x} ]; then export ENABLE_NEOVIM_BUILD="0"; fi # Set to "1" if you want to build Neovim from source.
  if [ -z ${INSTALL_DIR+x} ]; then export INSTALL_DIR="/opt/${IDE_NAME}"; fi
  if [ -z ${WORKSPACE_DIR+x} ]; then export WORKSPACE_DIR="/root/${IDE_NAME}-workspace"; fi
}

read_user_configuration

# Persist user configuration
function persist_user_configuration() {
  export CONFIG_DIR="/etc/pojde"
  mkdir -p "${CONFIG_DIR}"

  echo "export FULL_NAME=\"${FULL_NAME}\"" >${CONFIG_DIR}/config.sh
  echo "export MOTD=\"${MOTD}\"" >>${CONFIG_DIR}/config.sh
  echo "export THEIA_IDE_DESCRIPTION=\"${THEIA_IDE_DESCRIPTION}\"" >>${CONFIG_DIR}/config.sh
  echo "export EMAIL=\"${EMAIL}\"" >>${CONFIG_DIR}/config.sh
  echo "export GITHUB_USERNAME=\"${GITHUB_USERNAME}\"" >>${CONFIG_DIR}/config.sh
  echo "export USERNAME=\"${USERNAME}\"" >>${CONFIG_DIR}/config.sh
  echo "export PASSWORD=\"${PASSWORD}\"" >>${CONFIG_DIR}/config.sh
  echo "export DOMAIN=\"${DOMAIN}\"" >>${CONFIG_DIR}/config.sh
  echo "export IP=\"${IP}\"" >>${CONFIG_DIR}/config.sh
  echo "export NAMESERVER=\"${NAMESERVER}\"" >>${CONFIG_DIR}/config.sh
  echo "export SCREEN_RESOLUTION=\"${SCREEN_RESOLUTION}\"" >>${CONFIG_DIR}/config.sh
  echo "export ENABLE_OS_SETUP=\"${ENABLE_OS_SETUP}\"" >>${CONFIG_DIR}/config.sh
  echo "export ENABLE_MONO_BUILD=\"${ENABLE_MONO_BUILD}\"" >>${CONFIG_DIR}/config.sh
  echo "export ENABLE_NEOVIM_BUILD=\"${ENABLE_NEOVIM_BUILD}\"" >>${CONFIG_DIR}/config.sh
  echo "export ENABLE_SECOPS_TOOLS=\"${ENABLE_SECOPS_TOOLS}\"" >>${CONFIG_DIR}/config.sh
  echo "export IDE_NAME=\"${IDE_NAME}\"" >>${CONFIG_DIR}/config.sh
  echo "export INSTALL_DIR=\"${INSTALL_DIR}\"" >>${CONFIG_DIR}/config.sh
  echo "export WORKSPACE_DIR=\"${WORKSPACE_DIR}\"" >>${CONFIG_DIR}/config.sh
}

persist_user_configuration

# Setup the base operating system
function setup_operating_system() {
  if [ $ENABLE_OS_SETUP = "1" ]; then
    # Set timezone to UTC by default
    setup-timezone -z UTC

    # Setup networking
    cat <<-EOF >/etc/network/interfaces
		iface lo inet loopback
		iface eth0 inet dhcp
	EOF

    # Enable networking
    ln -s networking /etc/init.d/net.lo
    ln -s networking /etc/init.d/net.eth0

    rc-update add net.eth0 default
    rc-update add net.lo boot
  fi

  # Set custom message of the day
  cat <<EOF >/etc/motd
${MOTD}
EOF

  # Set the custom nameserver
  echo "nameserver $NAMESERVER" >/etc/resolv.conf

  # Get and set the user's SSH keys
  mkdir -m 700 -p /root/.ssh
  wget -O - https://github.com/${GITHUB_USERNAME}.keys | tee /root/.ssh/authorized_keys
  chmod 600 /root/.ssh/authorized_keys

  # Allow TCP forwarding via SSH
  sed -i 's/AllowTcpForwarding no/AllowTcpForwarding yes/g' /etc/ssh/sshd_config

  # Give root privileges to other users
  usermod -p '*' root

  # Make bash the default shell
  ln -sf /bin/bash /bin/sh

  # Install system updates
  apk update
  apk upgrade

  # Get the system architecture
  export SYSTEM_ARCHITECTURE=$(uname -m)
}

setup_operating_system

function install_go() {
  # Install toolchain
  apk add go

  # Setup WebAssembly support
  mkdir -p /usr/lib/go/misc/wasm/
  curl -L -o /usr/lib/go/misc/wasm/wasm_exec.js https://raw.githubusercontent.com/golang/go/master/misc/wasm/wasm_exec.js
}

install_go

if [ $SYSTEM_ARCHITECTURE = "x86_64" ]; then
  curl -L -o /tmp/alpimager https://github.com/pojntfx/alpimager/releases/download/unstable-linux/alpimager
  install /tmp/alpimager /usr/local/bin
fi

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
ln -sf /etc/profile.d/color_prompt /etc/profile.d/color_prompt.sh

source /root/.bashrc

git config --global user.name "${FULL_NAME}"
git config --global user.email "${EMAIL}"
git config --global pull.rebase false
git config --global init.defaultBranch main

rm -rf ${INSTALL_DIR}
mkdir -p ${INSTALL_DIR}

if [ $ENABLE_MONO_BUILD = "1" ]; then
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
else
  apk add mono mono-dev mono-doc mono-lang
fi

curl -L https://dot.net/v1/dotnet-install.sh | bash -s -- -c Current --install-dir /usr/share/dotnet
ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

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

sed -i 's/\#text\/html/text\/html/g' /root/.config/aerc/aerc.conf

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
  "[shellscript]": {
    "editor.defaultFormatter": "foxundermoon.shell-format"
  },
  "[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "keyboard.dispatch": "keyCode"
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
openvsx_extensions_noarch=(
  eamodio/gitlens
  mhutchie/git-graph
  esbenp/prettier-vscode
  vscodevim/vim
  vscode/markdown
  vscode/yaml
  redhat/vscode-yaml
  bungcip/better-toml
  vscode/json
  vscode/json-language-featur
  zxh404/vscode-proto3
  Prisma/vscode-graphql
  vscode/xml
  redhat/vscode-xml
  hediet/vscode-drawio
  vscode/image-preview
  vscode/shellscript
  foxundermoon/shell-format
  vscode/cpp
  webfreak/debug
  llvm-vs-code-extensions/vsc
  twxs/cmake
  vscode/make
  matepek/vscode-catch2-test-
  vscode/rust
  matklad/rust-analyzer
  serayuzgur/crates
  vscode/go
  golang/Go
  vscode/java
  redhat/java
  vscjava/vscode-java-debug
  vscjava/vscode-java-test
  vscjava/vscode-maven
  richardwillis/vscode-gradle
  vscjava/vscode-java-depende
  vscode/python
  ms-python/python
  vscode/ruby
  rebornix/ruby
  vscode/javascript
  vscode/typescript
  vscode/typescript-language-features
  vscode/npm
  Orta/vscode-jest
  ms-vscode/node-debug
  ms-vscode/node-debug2
  ms-vscode/js-debug
  msjsdiag/debugger-for-chrome
  firefox-devtools/vscode-firefox-debug
  vscode/html
  vscode/html-language-features
  vscode/css
  vscode/css-language-features
  jpoissonnier/vscode-styled-components
  octref/vetur
  vscode/emmet
  vscode/sql
  geequlim/godot-tools
  vscode/docker
  ms-azuretools/vscode-docker
  ms-kubernetes-tools/vscode-kubernetes-tools
  valentjn/vscode-ltex
  James-Yu/latex-workshop
  alefragnani/project-manager
  EdgardMessias/clipboard-manager
  jock/svg
  jebbs/plantuml
  bradlc/vscode-tailwindcss
  42Crunch/vscode-openapi
  foam/foam-vscode
  kortina/vscode-markdown-notes
  tchayen/markdown-links
  yzhang/markdown-all-in-one
  vscode/csharp
  k--kato/docomment
  muhammad-sammy/csharp
  ms-vscode/cmake-tools
  GitHub/github-vscode-theme
  dracula-theme/theme-dracula
  Equinusocio/vsc-material-theme
  Equinusocio/vsc-material-theme-icons
  prime31/zig
  arcanis/vscode-zipfs
  arcticicestudio/nord-visual-studio-code
  akamud/vscode-theme-onelight
  akamud/vscode-theme-onedark
)

openvsx_extensions_amd64=(
  kiteco/kite
)

# Extensions from GitHub (second best option)
github_extensions_noarch=(
  redhat-developer/omnisharp-theia-plugin/releases/download/v0.0.6/omnisharp_theia_plugin.theia
  cheshirekow/cmake_format/releases/download/v0.6.13/cmake-format-0.6.13.vsix
  tinygo-org/vscode-tinygo/releases/download/0.2.0/vscode-tinygo-0.2.0.vsix
)

# Extensions from MS marketplace (worst option; rate limited)
vscode_marketplace_extensions_noarch=(
  madhavd1/vsextensions/javadoc-tools/1.4.0
  lorenzopirro/vsextensions/zig-snippets/1.3.0
  mtxr/vsextensions/sqltools-driver-mysql/0.2.0
  mtxr/vsextensions/sqltools-driver-sqlite/0.2.0
  mtxr/vsextensions/sqltools-driver-pg/0.2.0
  MaxvanderSchee/vsextensions/web-accessibility/0.2.83
  naco-siren/vsextensions/gradle-language/0.2.3
  dsznajder/vsextensions/es7-react-js-snippets/3.1.0
  mtxr/vsextensions/sqltools/0.23.0
  tinkertrain/vsextensions/theme-panda/1.3.0
  miguelsolorio/vsextensions/min-theme/1.4.7
  ahmadawais/vsextensions/shades-of-purple/6.12.0
  jolaleye/vsextensions/horizon-theme-vscode/2.0.2
  taniarascia/vsextensions/new-moon-vscode/1.8.8
  ms-vscode/vsextensions/mono-debug/0.16.2
  Tyriar/vsextensions/lorem-ipsum/1.2.0
  tomoki1207/vsextensions/pdf/1.1.0
  cmstead/vsextensions/jsrefactor/2.20.6
)

function download_extension_from_openvsx() {
  curl "https://open-vsx.org/api/${1}" | jq '.files.download' | xargs curl --compressed -L -o "plugins/openvsx_${2}".vsix
}

function download_extension_from_github() {
  curl --compressed -L -o "plugins/github_${2}".vsix "https://github.com/${1}"
}

function download_extension_from_vscode_marketplace() {
  curl --compressed -L -o "plugins/vscode_marketplace-${2}".vsix "https://marketplace.visualstudio.com/_apis/public/gallery/publishers/${1}/vspackage"
}

for i in ${!openvsx_extensions_noarch[@]}; do
  download_extension_from_openvsx ${openvsx_extensions_noarch[$i]} ${i}
done

if [ $SYSTEM_ARCHITECTURE = "x86_64" ]; then
  for i in ${!openvsx_extensions_amd64[@]}; do
    download_extension_from_openvsx ${openvsx_extensions_amd64[$i]} ${i}
  done
fi

for i in ${!github_extensions_noarch[@]}; do
  download_extension_from_github ${github_extensions_noarch[$i]} ${i}
done

for i in ${!vscode_marketplace_extensions_noarch[@]}; do
  download_extension_from_vscode_marketplace ${vscode_marketplace_extensions_noarch[$i]} ${i}
done

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

rm ${INSTALL_DIR}/theia/plugins/omnisharp_theia_plugin.vsix-extracted/.omnisharp/bin/mono
ln -s $(which mono) ${INSTALL_DIR}/theia/plugins/omnisharp_theia_plugin.vsix-extracted/.omnisharp/bin/mono

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

echo "Almost done! In order to continue, please open the following link:"

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
