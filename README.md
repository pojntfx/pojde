# pojde

```plaintext
                   _     __
    ____  ____    (_)___/ /__
   / __ \/ __ \  / / __  / _ \
  / /_/ / /_/ / / / /_/ /  __/
 / .___/\____/_/ /\__,_/\___/
/_/         /___/

```

Headless Linux distribution for full-stack software development with web access for all components. Runs as a Docker container, virtual machine or even on bare metal. Develop from anywhere using any device with a browser!

[🚀 Get started](#installation)

## Overview

### Services

- [ttyd](https://github.com/tsl0922/ttyd), a web terminal
- My distribution of [Theia](https://theia-ide.org/), a modular web IDE based on VSCode
- My distribution of [code-server](https://github.com/cdr/code-server), a fork of VSCode that turns it into a web IDE
- [noVNC](https://novnc.com/info.html), a web VNC client with a full desktop environment (see [Desktop](#desktop))

### Collaboration and Comfort

- GitLens
- Git Graph
- Gource
- Prettier
- Vim
- Project manager
- Clipboard manager
- speedtest-cli
- webtorrent-hybrid
- WebWormhole CLI
- [Foam](https://foambubble.github.io/foam/) and it's recommended extensions

### Data and Documentation

- Markdown language basics
- Markdown language support
- YAML language basics
- YAML language support
- TOML language support
- JSON language basics
- JSON language support
- Protobuf language support
- GraphQL language support
- OpenAPI/Swagger language support
- XML language basics
- XML language support
- Draw.io integration
- Image Preview
- SVG language support and preview
- LTeX (grammar/spell checker)
- LaTeX Workshop (with a full `texlive` installation)
- PDF viewer
- PlantUML
- node-plantuml
- mdBook

### Shell

- Shell Script language basics
- Shell Formatter

### C/C++

- C/C++ language basics
- C/C++ language support
- C/C++ debugging with GDB and LLDB
- CMake language basics
- CMake tools
- CMake formatter
- Make language basics
- C++ test explorer

### Rust

- Rust language basics
- Rust language support
- Crates

### Go

- Go language basics
- Go language support
- TinyGo support
- Go kernel for Jupyter

### Java

- Java language basics
- Java language support
- Debugger for Java
- Java test runner
- Maven for Java
- Gradle tasks
- Gradle language support
- Project manager for Java
- JavaDoc Tools
- Java kernel for Jupyter

### C#

- C# language basics
- C# language support
- C# debugging with Mono (see https://marketplace.visualstudio.com/items?itemName=ms-vscode.mono-debug) for a launch configuration
- C# XML documentation comments
- .NET
- .NET kernel for Jupyter
- PowerShell language basics
- PowerShell language support
- PowerShell (X86_64 only)
- PowerShell kernel for Jupyter

### Godot

> GDScript language support in Theia is not yet working; trying to connect to the GDScript language server hangs in the "Connecting" state. Use the included Godot editor (see [Desktop](#desktop)) or code-server instead.

- Godot editor support
- GDScript language basics (in Theia and Godot Editor)
- GDScript language support (in Theia and Godot Editor)
- `.tscn` and `.tres` language basics (in Theia and Godot Editor)

### Python

- Python language basics
- Python language support
- Kite Autocomplete for Python
- Jupyter Lab (see [Access](#access))
- Python kernel for Jupyter
- Miniconda

### Octave

- Octave editor
- Octave language support
- Octave debugging
- Octave kernel for Jupyter

### Ruby

- Ruby language basics
- Ruby language support
- Ruby kernel for Jupyter

### JavaScript/TypeScript and Web Technologies

- JavaScript language basics
- TypeScript language basics
- TypeScript and JavaScript language features
- ES7 React/Redux/GraphQL/React-Native snippets
- NPM support (to debug scripts, use a launch configuration, not right click -> debug)
- Jest support
- NodeJS debugging
- Chrome debugging
- Firefox debugging
- HTML language basics
- HTML language features
- CSS, LESS and SCSS language basics
- CSS, LESS and SCSS language features
- Vetur
- Styled Components
- Emmet
- ZipFS
- Kite Autocomplete for JavaScript
- `wasmtime`
- localtunnel
- Lorem ipsum generator
- Tailwind CSS IntelliSense
- [Web Accessibility](https://github.com/mvdschee/web-accessibility)
- JS kernel for Jupyter

### Zig

- Zig language basics
- Zig language support
- Zig snippets

### R

- R language basics
- R language support
- R kernel for Jupyter

### Databases

- SQL language basics
- SQLite
- PostgreSQL Client
- MariaDB Client
- SQLTools
- SQLTools PostgreSQL Driver
- SQLTools SQLite Driver
- SQLTools MySQL Driver

### DevOps

- `arkade` (see [https://github.com/alexellis/arkade](https://github.com/alexellis/arkade))
- `kubectl` (see [https://kubernetes.io/docs/reference/kubectl/overview/](https://kubernetes.io/docs/reference/kubectl/overview/))
- `k9s` (see [https://k9scli.io/](https://k9scli.io/))
- `helm` (see [https://helm.sh/](https://helm.sh/))
- `skaffold` (see [https://skaffold.dev/](https://skaffold.dev/))
- `k3d` (see [https://k3d.io/](https://k3d.io/))
- `k3sup` (see [https://k3sup.dev/](https://k3sup.dev/))
- `alpimager` (see [https://github.com/pojntfx/alpimager](https://github.com/pojntfx/alpimager))
- `jq`
- Docker
- Podman
- Kubernetes
- `libvirt`
- Virtual Machine Manager
- GNOME Boxes
- Remmina
- Heroku CLI
- `serve`
- `iperf3`
- `upx`
- `zsh`
- WINE
- Bash kernel for Jupyter

### SecOps

- `tmux`
- `iproute2`
- `wireshark`
- `tshark`
- `iftop`
- `iotop`
- `nmap`
- Burp Suite
- `gobuster`
- `ffuf`
- John the Ripper
- Nikto
- `sqlmap`
- Metasploit
- `hydra`
- WPScan
- OWASP ZAP

### Themes

- Light (Theia)
- Dark (Theia)
- Panda
- Eva
- Min
- One Light
- One Dark
- Shades of Purple
- Dracula
- Horizon
- New Moon
- GitHub
- Material Theme
- Material Theme Icons
- Nord

### Desktop

- XFCE4
- Chromium
- Firefox
- GNOME Web (Epiphany/WebKit)
- Lynx
- Links
- w3m
- aerc
- Godot Editor
- Flatpak
- On-Screen Keyboard
- youtube-dl
- spotify-dl
- ffmpeg
- Handbrake
- ImageMagick

## Installation

### Option 1: Docker

To install, run the following in your terminal (ZSH, Bash or PowerShell) and follow the instructions:

```bash
docker run --name pojde -v $HOME/Documents/pojde:/root/Documents:z -p 8022:22 -p 8000:8000 -p 8001:8001 -p 8002:8002 -p 8003:8003 -e HOME=/root -e USER=root -e DOCKER_HOST="unix:///opt/pojde/docker.sock" -e DISPLAY=":1" -v /var/run/docker.sock:/opt/pojde/docker.sock:z --dns 8.8.8.8 -d --privileged --restart always pojntfx/alpine-openrc:edge
docker exec -it pojde sh -c 'wget -O /tmp/install.sh https://raw.githubusercontent.com/pojntfx/pojde/master/update-pojde && sh /tmp/install.sh && sleep 10 && exit'
```

You can find the content of the container's `Documents` folder in the `Documents/pojde` folder of your Docker host for easy data transfer.

For the next steps, continue to [Usage](#usage).

> Tested on:
>
> - Alpine Linux Edge with Docker 19.03.13 (x86_64) (Intel Server)
> - Alpine Linux Edge with Docker 19.03.13 (aarch64) (Raspberry Pi 4)
> - Fedora Linux 33 with Docker 19.03.13 (Intel Workstation)
> - macOS Big Sur with Docker 19.03.13 (MacBook Pro 2016 13")
> - Windows 10 2004 with Docker 19.03.13 (Intel Workstation)

### Option 2: Native Installation On An Existing Alpine Linux Installation

To install, run the following as root and follow the instructions:

```bash
sh -c "$(wget -O - https://raw.githubusercontent.com/pojntfx/pojde/master/update-pojde)"
```

For the next steps, continue to [Usage](#usage).

> Tested on:
>
> - Alpine Linux Edge (x86_64) (Intel Server)
> - Alpine Linux Edge (aarch64) (Raspberry Pi 4)
> - Windows 10 2004 using WSL2 with [Alpine WSL](https://www.microsoft.com/en-us/p/alpine-wsl/9p804crf0395); if there are errors in the installation script, you can safely ignore them. Because of the way that WSL works, there is no support for the init system, so you'll have to start the IDE manually by running `supervisord -c /etc/supervisord.conf` as root. SSH forwarding is supported if OpenSSH server is enabled on Windows (see [Installation of OpenSSH For Windows Server 2019 and Windows 10](https://docs.microsoft.com/en-us/windows-server/administration/openssh/openssh_install_firstuse)), but you'll have to specify the IP of the WSL virtual machine (i.e. by substituting `-L localhost:8000:localhost:8000` etc. with `-L localhost:8000:172.19.201.219:8000`). You can find the IP of the WSL virtual machine by running `ip addr` in Alpine WSL's shell.

### Option 3: Virtualized Installation With `alpimager`

1. Copy [packages.txt](https://github.com/pojntfx/pojde/blob/master/packages.txt), [repositories.txt](https://github.com/pojntfx/pojde/blob/master/repositories.txt) and [setup.sh](https://github.com/pojntfx/pojde/blob/master/setup.sh) to a local directory.
2. Change usernames, passwords, SSH public keys etc. in `setup.sh` to your liking
3. Get [alpimager](https://pojntfx.github.io/alpimager/), install it and create the disk image by running `alpimager -output pojde.qcow2 -debug`. If there are issues with the `nbd` kernel module, run `modprobe nbd` on your Docker host.
4. Increase the disk image size by running `qemu-img resize pojde.qcow2 +20G`
5. Start the virtual machine by running `qemu-system-x86_64 -m 4096 -accel kvm -nic user,hostfwd=tcp::8022-:22 -boot d -drive format=qcow2,file=pojde.qcow2`; use `-accel hvf` or `-accel hax` on macOS, `-accel kvm` on Linux. We are using a user net device with port forwarding in this example, but if you are using Linux as your host os, it is also possible to set up a [bridge](https://wiki.alpinelinux.org/wiki/Bridge) to access the VM from a dedicated IP from your host network and then start it by running `qemu-system-x86_64 -m 4096 -accel kvm -net nic -net bridge,br=br0 -boot d -drive format=qcow2,file=pojde.qcow2`. If you do so, there is no need to use `-p 8022` flag in the `ssh` commands below and you should replace `localhost` with the IP of the VM. Also, if you prefer not to use a graphical display, pass the `-nographic` flag to the startup commands above.
6. Log into the machine and resize the file system by running `ssh -p 8022 root@localhost resize2fs /dev/sda`. If you're running in a public cloud `/dev/sda` might be something else such as `/dev/vda`.
7. Setup secure access by running `ssh -L localhost:8000:localhost:8000 -L localhost:8001:localhost:8001 -L localhost:8002:localhost:8002 -L localhost:8003:localhost:8003 -L localhost:8004:localhost:8004 -p 8022 root@localhost`. If you do not setup secure access like so, the might be issues with webviews in Theia.
8. Continue to [Usage](#usage)

> Tested on:
>
> - Alpine Linux Edge (x86_64) (Intel Server)
> - Fedora Linux 33 (Intel Workstation)
> - macOS Big Sur (MacBook Pro 2016 13")

For Windows, please use the native installation on WSL2 (see [the alpimager docs](https://github.com/pojntfx/alpimager#installation) for why).

## Usage

### Trusting the Certificates

At the end of the installation script, the script asked you to click a link, which downloaded the root certificate to your device. You'll now have to trust that SSL certificate. I created some videos on how to do that; please note that you don't have to download the certificate as described in the videos, but instead have to use the root certificate you've downloaded earlier:

- [Trusting self-signed SSL certificates (Chrome on macOS)](https://www.youtube.com/watch?v=_PJc7RcMnw8)
- [Trusting self-signed SSL certificates (Chrome on Linux)](https://www.youtube.com/watch?v=byFN8vH2SaM)
- [Trusting self signed SSL certificates (Chrome on Windows)](https://www.youtube.com/watch?v=gyQ9IIxE3vc)

If you are using a iOS device, read the following article: [Adding Trusted Root Certificates to iOS14](https://www.theictguy.co.uk/adding-trusted-root-certificates-to-ios14/). [code-server/issues/979](https://github.com/cdr/code-server/issues/979#issuecomment-557902494) might also be of use.

If you prefer to use another browser on Linux or require the certificate to be installed system-wide, check out [How to add trusted CA certificate on CentOS/Fedora](https://www.devdungeon.com/content/how-add-trusted-ca-certificate-centosfedora).

Note that Safari is not supported in Theia due to an [issue with WebSockets and HTTP basic auth](https://bugs.webkit.org/show_bug.cgi?id=80362). To use Theia on Safari, open noVNC, add it to the homescreen and use Chromium in noVNC to browse to Theia; alternatively, you can use code-server.

### Access

To access the services, use the passwords you've specified in `setup.sh` and the addresses below. The default username is `pojntfx`, the default password is `mysvcpassword`. If you don't use SSH forwarding, didn't install using Docker or are on the machine that runs the IDE, you'll most likely want to replace `localhost` with the IP or domain of the machine that is running the IDE, i.e. `myide.example.com` or `192.168.178.23`.

- ttyd: [https://localhost:8000](https://localhost:8000)
- Theia: [https://localhost:8001](https://localhost:8001)
- code-server: [https://localhost:8002](https://localhost:8002)
- noVNC: [https://localhost:8003](https://localhost:8003)
- Jupyter Lab: [https://localhost:8004](https://localhost:8004)

If you chose the Docker or virtualized installation options, you can also SSH into the container/virtual machine with `ssh -p 8022 root@localhost`.

If you are accessing the services on localhost and trust the SSL certificate, please note that [HSTS](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security) will be enabled for localhost. To prevent having HSTS on localhost, you may want to access the services using `localhost.localdomain` or `local.local` instead.

Additionally, for `code-server`, some additional shortcuts for better cross-browser support have been added:

- `alt + w`/`opt + w` is an alias of `ctrl + w`/`cmd + c + w`, which closes the active editor.
- `alt + shift + p`/`opt + shift + p` is an alias of `ctrl + shift + p`/`cmd + shift + p`, which opens the command palette.

If you use Chrome, Edge or Brave, installing `code-server` as a PWA allows you to use shortcuts such as `cmd + tab`/`ctrl + tab` or `cmd - w`/`ctrl - w` directly.

> Tested on:
>
> - Chrome 88
> - Firefox 85
> - Safari 14
> - Web 3.38.2
> - Edge 88
> - Brave 1.19.88

### Using a Domain

If you are using a domain, make sure to set the `A` and `AAAA` records correctly:

```zone
A dev.felicitas.pojtinger.com 141.72.248.134
AAAA dev.felicitas.pojtinger.com 2001:7c7:2121:8d00:da47:32ff:fec9:62a0
A *.webview.dev.felicitas.pojtinger.com 141.72.248.134
AAAA *.webview.dev.felicitas.pojtinger.com 2001:7c7:2121:8d00:da47:32ff:fec9:62a0
```

### Updating

To update the IDE, run `update-pojde` in the terminal and follow the instructions.

## License

pojde (c) 2021 Felicitas Pojtinger

SPDX-License-Identifier: AGPL-3.0
