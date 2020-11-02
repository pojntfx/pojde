#!/bin/bash

## Configure your IDE here
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
if [ -z ${SCREEN_RESOLUTION+x} ]; then export SCREEN_RESOLUTION="1400x1050"; fi
if [ -z ${ENABLE_OS_SETUP+x} ]; then export ENABLE_OS_SETUP="1"; fi             # Set to "0" if you're not running this on a fresh system
if [ -z ${ENABLE_CSHARP_SUPPORT+x} ]; then export ENABLE_CSHARP_SUPPORT="0"; fi # Set to "1" if you want C# support; compiling Mono can take some time.
if [ -z ${ENABLE_NEOVIM_BUILD+x} ]; then export ENABLE_NEOVIM_BUILD="0"; fi     # Set to "1" if you want to have the latest neovim version from Git instead of the repository version
if [ -z ${INSTALL_DIR+x} ]; then export INSTALL_DIR="/opt/${IDE_NAME}"; fi
if [ -z ${WORKSPACE_DIR+x} ]; then export WORKSPACE_DIR="/root/${IDE_NAME}-workspace"; fi
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
export PATH="\$PATH:/root/.arkade/bin/"
export WASMTIME_HOME="\$HOME/.wasmtime"
export PATH="\$WASMTIME_HOME/bin:\$PATH"
export PATH="/usr/local/bin/:\$PATH"

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
else
  apk add neovim
fi

ln -sf /usr/local/bin/nvim /usr/bin/nvim
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

chmod +x ~/Desktop/Chromium.desktop
chmod +x ~/Desktop/Onboard.desktop

curl -L -o /usr/share/backgrounds/xfce/spacex.jpg 'https://images.unsplash.com/photo-1541185934-01b600ea069c?ixlib=rb-1.2.1&q=80&fm=jpg&crop=entropy&cs=tinysrgb&dl=spacex-6SbFGnQTE8s-unsplash.jpg'
xfconf-query -c xfce4-desktop -l | grep last-image | while read path; do xfconf-query -c xfce4-desktop -p $path -s /usr/share/backgrounds/xfce/spacex.jpg; done

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

if [ $SYSTEM_ARCHITECTURE = "x86_64" ]; then
  echo -ne '\ny\n\n' | bash -c "$(wget -q -O - https://linux.kite.com/dls/linux/current)"

  cat <<EOT >/etc/init.d/kited
#!/sbin/openrc-run                                                                                                                                                                                                    

name=\$RC_SVCNAME
command="/root/.local/share/kite/kited"
pidfile="/run/\$RC_SVCNAME.pid"
command_background="yes"
EOT
  chmod +x /etc/init.d/kited
fi

pip install -U pylint --user
pip install -U autopep8 --user

curl https://wasmtime.dev/install.sh -sSf | bash

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

yarn global add wetty@1.4.1
yarn global add jest
yarn global add @vue/cli
yarn global add localtunnel
yarn global add code-server

rm -rf ~/.config/code-server
mkdir -p ~/.config/code-server
rm -rf ~/.local/share/code-server
mkdir -p ~/.local/share/code-server/User
cat <<EOT >~/.config/code-server/config.yaml
bind-addr: 0.0.0.0:8002
auth: password
password: ${PASSWORD}
cert: /etc/nginx/server.crt
cert-key: /etc/nginx/server.key
EOT

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
  }
]
EOT
cp ~/.theia/keymaps.json ~/.local/share/code-server/User/keybindings.json

cat <<EOT >~/.local/share/code-server/User/settings.json
{
  "workbench.iconTheme": "eq-material-theme-icons",
  "workbench.colorTheme": "GitHub Dark",
  "go.autocompleteUnimportedPackages": true,
  "go.useLanguageServer": true,
  "vim.debug.silent": true,
  "sqltools.useNodeRuntime": true,
  "files.enableTrash": false,
  "cmake.configureOnOpen": true,
  "cmake.debugConfig": {
    "type": "lldb-mi",
    "request": "launch",
    "target": "\${command:cmake.launchTargetPath}",
    "args": [],
    "cwd": "\${workspaceFolder}"
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
  "editor.smoothScrolling": true,
  "kite.showWelcomeNotificationOnStartup": false,
  "clangd.path": "/usr/bin/clangd",
  "git.autofetch": true,
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
rm -rf ~/.local/share/code-server/extensions/

mkdir -p plugins

# Extensions from Open-VSX (preferred method)
curl 'https://open-vsx.org/api/eamodio/gitlens' | jq '.files.download' | xargs curl --compressed -L -o plugins/gitlens.vsix
curl 'https://open-vsx.org/api/mhutchie/git-graph' | jq '.files.download' | xargs curl --compressed -L -o plugins/git-graph.vsix
curl 'https://open-vsx.org/api/esbenp/prettier-vscode' | jq '.files.download' | xargs curl --compressed -L -o plugins/prettier-vscode.vsix
curl 'https://open-vsx.org/api/vscodevim/vim/1.16.0' | jq '.files.download' | xargs curl --compressed -L -o plugins/vim.vsix # Locked to work with code-server
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

if [ $ENABLE_CSHARP_SUPPORT = "1" ]; then
  curl 'https://open-vsx.org/api/vscode/csharp' | jq '.files.download' | xargs curl --compressed -L -o plugins/csharp.vsix
  curl 'https://open-vsx.org/api/k--kato/docomment' | jq '.files.download' | xargs curl --compressed -L -o plugins/docomment.vsix
fi

# Extensions from GitHub (second best option)
curl --compressed -L -o plugins/omnisharp_theia_plugin.vsix https://github.com/redhat-developer/omnisharp-theia-plugin/releases/download/v0.0.6/omnisharp_theia_plugin.theia
curl --compressed -L -o plugins/cmake-format.vsix https://github.com/cheshirekow/cmake_format/releases/download/v0.6.13/cmake-format-0.6.13.vsix

# Extensions from code-server marketplace (third best open)
code-server --force --install-extension '42crunch.vscode-openapi'
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

# Extensions from MS marketplace (worst option; rate limited)
curl --compressed -L -o plugins/vscode-javadoc-tools.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/madhavd1/vsextensions/javadoc-tools/1.4.0/vspackage
curl --compressed -L -o plugins/zig-snippets.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/lorenzopirro/vsextensions/zig-snippets/1.3.0/vspackage
curl --compressed -L -o plugins/zig.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/tiehuis/vsextensions/zig/0.2.5/vspackage
curl --compressed -L -o plugins/vscode-zipfs.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/arcanis/vsextensions/vscode-zipfs/2.2.2/vspackage
curl --compressed -L -o plugins/theme-monokai-pro-vscode.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/monokai/vsextensions/theme-monokai-pro-vscode/1.1.17/vspackage
curl --compressed -L -o plugins/sqltools-driver-mysql.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-mysql/0.2.0/vspackage
curl --compressed -L -o plugins/sqltools-driver-sqlite.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-sqlite/0.2.0/vspackage
curl --compressed -L -o plugins/sqltools-driver-pg.vsix https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-pg/0.2.0/vspackage

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

yarn
yarn theia build

x11vnc -storepasswd ${PASSWORD} /etc/vncsecret

fc-cache -f

printf "${DOMAIN}-${IP}" >/etc/nginx/domain-ip
if [ "$(cat /etc/nginx/domain-ip)" != "${DOMAIN}-${IP}" ]; then
  openssl req -x509 -newkey rsa:4096 -sha256 -days 3650 -nodes \
    -keyout /etc/nginx/server.key -out /etc/nginx/server.crt -subj "/CN=localhost" \
    -addext "subjectAltName=DNS:localhost,DNS:*.webview.localhost,DNS:${DOMAIN},DNS:*.webview.${DOMAIN},IP:${IP}"
fi

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
directory=${INSTALL_DIR}/theia
command=/usr/bin/yarn theia start ${WORKSPACE_DIR} --hostname 127.0.0.1 --port 3001 --plugins=local-dir:plugins --vscode-api-version=1.50.1
user=root
autorestart=true

[program:xvfb]
priority=300
command=/usr/bin/Xvfb :1 -screen 0 ${SCREEN_RESOLUTION}x24 +iglx
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
command=/usr/bin/novnc_server --vnc localhost:5900 --listen 3003
user=root
autorestart=true

[program:nginx]
priority=700
command=/bin/sh -c "mkdir -p /run/nginx && /usr/sbin/nginx -g 'daemon off;' -c /etc/nginx/nginx.conf"
user=root
autorestart=true

[program:code-server]
priority=800
command=/usr/local/bin/code-server
user=root
autorestart=true
EOT

curl -o /usr/local/bin/update-pojde https://raw.githubusercontent.com/pojntfx/pojde/master/update-pojde
chmod +x /usr/local/bin/update-pojde

echo "Setup completed successfully; you might loose your connection if you're connected via SSH or are using one of the services. In that case, please reconnect/reload."

services="dbus udev fuse docker supervisord"
if [ $SYSTEM_ARCHITECTURE = "x86_64" ]; then
  services="dbus udev fuse docker kited supervisord"
fi
for service in $services; do
  nohup /bin/sh -c "rc-update add $service default; rc-service $service restart" >/dev/null 2>&1 &
done
