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

[Get started](#installation)

## Overview

### Services

- [GoTTY](https://github.com/yudai/gotty), a web terminal
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
- [Dendron](https://www.dendron.so/)

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

### C#

- C# language basics
- C# language support
- C# debugging with Mono (see https://marketplace.visualstudio.com/items?itemName=ms-vscode.mono-debug) for a launch configuration
- C# XML documentation comments

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

### Ruby

- Ruby language basics
- Ruby language support

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

### Zig

- Zig language basics
- Zig language support
- Zig snippets

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
- Kubernetes
- `libvirt`
- Virtual Machine Manager
- GNOME Boxes
- Remmina

### SecOps

- `tmux`
- `iproute2`
- `wireshark`
- `tshark`
- `iftop`
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
- Monokai Pro
- Shades of Purple
- Dracula
- Horizon
- New Moon
- GitHub
- Material Theme
- Material Theme Icons

### Desktop

- XFCE4
- Chromium
- Firefox
- GNOME Web (Epiphany/WebKit)
- Lynx
- Godot Editor
- Flatpak
- On-Screen Keyboard

## Installation

### Option 1: Docker

To install, run the following in your terminal (ZSH, Bash or PowerShell) and follow the instructions:

```bash
docker run --name pojde -v $HOME/Documents/pojde:/root/Documents:z -p 8022:22 -p 8000:8000 -p 8001:8001 -p 8002:8002 -p 8003:8003 -e HOME=/root -v /var/run/docker.sock:/var/run/docker.sock:z -d --privileged --restart always pojntfx/alpine-openrc:edge
docker exec -it pojde sh -c 'echo nameserver\ 8.8.8.8 > /etc/resolv.conf && wget -O /tmp/install.sh https://raw.githubusercontent.com/pojntfx/pojde/master/update-pojde && sh /tmp/install.sh && sleep 10 && exit'
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
7. Setup secure access by running `ssh -L localhost:8000:localhost:8000 -L localhost:8001:localhost:8001 -L localhost:8002:localhost:8002 -L localhost:8003:localhost:8003 -p 8022 root@localhost`. If you do not setup secure access like so, the might be issues with webviews in Theia.
8. Continue to [Usage](#usage)

> Tested on:
>
> - Alpine Linux Edge (x86_64) (Intel Server)
> - Fedora Linux 33 (Intel Workstation)
> - macOS Big Sur (MacBook Pro 2016 13")

For Windows, please use the native installation on WSL2 (see [the alpimager docs](https://github.com/pojntfx/alpimager#installation) for why).

## Usage

### Access

To access the services, use the passwords you've specified in `setup.sh` and the addresses below. The default username is `pojntfx`, the default password is `mysvcpassword`. If you don't use SSH forwarding, didn't install using Docker or are on the machine that runs the IDE, you'll most likely want to replace `localhost` with the IP or domain of the machine that is running the IDE, i.e. `myide.example.com` or `192.168.178.23`.

- GoTTY: [https://localhost:8000](https://localhost:8000)
- Theia: [https://localhost:8001](https://localhost:8001)
- code-server: [https://localhost:8002](https://localhost:8002)
- noVNC: [https://localhost:8003](https://localhost:8003)

If you are accessing the serivces on localhost and trust the SSL certificate, please note that [HSTS](https://en.wikipedia.org/wiki/HTTP_Strict_Transport_Security) will be enabled for localhost. To prevent having HSTS on localhost, you may want to access the services using `localhost.localdomain` or `local.local` instead.

### Using a Domain

If you are using a domain, make sure to set the A records correcty:

```zone
A pojntfx.dev.alphahorizon.io 141.72.248.134
A *.pojntfx.dev.alphahorizon.io 141.72.248.134
```

### Trusting the Certificates

You'll have to trust the self-signed SSL certificate. I created some videos on how to do that:

- [Trusting self-signed SSL certificates (Chrome on macOS)](https://www.youtube.com/watch?v=_PJc7RcMnw8)
- [Trusting self-signed SSL certificates (Chrome on Linux)](https://www.youtube.com/watch?v=byFN8vH2SaM)
- [Trusting self signed SSL certificates (Chrome on Windows)](https://www.youtube.com/watch?v=gyQ9IIxE3vc)

If you are using a iOS device, read the following article: [Adding Trusted Root Certificates to iOS14](https://www.theictguy.co.uk/adding-trusted-root-certificates-to-ios14/). [code-server/issues/979](https://github.com/cdr/code-server/issues/979#issuecomment-557902494) might also be of use.

Note that Safari is not supported in Theia due to an [issue with WebSockets and HTTP basic auth](https://bugs.webkit.org/show_bug.cgi?id=80362). To use Theia on Safari, open noVNC, add it to the homescreen and use Chromium in noVNC to browse to Theia; alternatively, you can use code-server.

### Updating

To update the IDE, run `update-pojde` in the terminal and follow the instructions.

## License

pojde (c) 2020 Felix Pojtinger

SPDX-License-Identifier: AGPL-3.0
