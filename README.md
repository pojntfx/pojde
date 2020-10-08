# Felicitas Pojtinger's Theia

My personal Theia distribution, optimized for full stack development.

## Overview

### Services

- [wetty](https://github.com/butlerx/wetty), a web terminal
- My distribution of [Theia](https://theia-ide.org/), a web IDE
- [noVNC](https://novnc.com/info.html), a web VNC client with a full desktop environment (see [Desktop](#desktop))

### Collaboration and Comfort

- GitLens
- Git Graph
- Prettier
- Vim

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
- Image Preview

### Shell

- Shell Script language basics
- Shell Formatter

### C/C++

- C/C++ language basics
- C/C++ language support
- C/C++ debugging with GDB and LLDB
- CMake language basics
- CMake tools
- Make language basics
- C++ test explorer

### Rust

- Rust language basics
- Rust language support

### Go

- Go language basics
- Go language support

### Java

- Java language basics
- Java language support
- Debugger for Java
- Java test runner
- Maven for Java
- Project manager for Java
- JavaDoc Tools

### C#

> To enable C#, set `ENABLE_CSHARP_SUPPORT` to `"1"` in `setup.sh`

- C# language basics
- C# language support
- C# debugging with Mono (see https://marketplace.visualstudio.com/items?itemName=ms-vscode.mono-debug) for a launch configuration
- C# XML documentation comments

### Godot

> GDScript language support in Theia is not yet working; trying to connect to the GDScript language server hangs in the "Connecting" state. Use the included Godot editor instead (see [Desktop](#desktop)).

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
- Docker language basics
- Kubernetes

### Themes

- Light (Theia)
- Dark (Theia)
- Panda
- Eva
- Min
- macOS Modern
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

### Virtualized Installation With `alpimager`

1. Copy [packages.txt](https://github.com/pojntfx/felicitas-pojtingers-theia/blob/master/packages.txt), [repositories.txt](https://github.com/pojntfx/felicitas-pojtingers-theia/blob/master/repositories.txt) and [setup.sh](https://github.com/pojntfx/felicitas-pojtingers-theia/blob/master/setup.sh) to a local directory. Do not delete these files after running the commands below; you'll need them again once you want to update the IDE.
2. Change usernames, passwords, SSH public keys etc. in `setup.sh` to your liking
3. First, get [alpimager](https://pojntfx.github.io/alpimager/), install it and create the disk image by running `alpimager -output felicitas-pojtingers-theia.qcow2 -debug`. If there are issues with the `nbd` kernel module, run `modprobe nbd` on your Docker host.
4. Increase the disk image size by running `qemu-img resize felicitas-pojtingers-theia.qcow2 +20G`
5. Start the virtual machine by running `qemu-system-x86_64 -m 4096 -accel kvm -nic user,hostfwd=tcp::40022-:22 -boot d -drive format=qcow2,file=felicitas-pojtingers-theia.qcow2`; use `-accel hvf` or `-accel hax` on macOS, `-accel kvm` on Linux. We are using a user net device with port forwarding in this example, but if you are using Linux as your host os, it is also possible to set up a [bridge](https://wiki.alpinelinux.org/wiki/Bridge) to access the VM from a dedicated IP from your host network and then start it by running `qemu-system-x86_64 -m 4096 -accel kvm -net nic -net bridge,br=br0 -boot d -drive format=qcow2,file=felicitas-pojtingers-theia.qcow2`. If you do so, there is no need to use `-p 40022` flag in the `ssh` commands below and you should replace `localhost` with the IP of the VM. Also, if you prefer not to use a graphical display, pass the `-nographic` flag to the startup commands above.
6. Log into the machine and resize the file system by running `ssh -p 40022 root@localhost resize2fs /dev/sda`. If you're running in a public cloud `/dev/sda` might be something else such as `/dev/vda`.
7. Setup secure access by running `ssh -L localhost:8000:localhost:8000 -L localhost:8001:localhost:8001 -L localhost:8002:localhost:8002 -p 40022 root@localhost`. If you do not setup secure access like so, the might be issues with webviews in Theia.
8. Continue to [Usage](#usage)

To update to a newer version of Theia, simply re-run the steps above. Make sure to persist your data somewhere that is not the VM beforehand; an update resets the VM. If you prefer to update without resetting the VM, see [Native Installation On An Existing Alpine Linux Installation](#native-installation-on-an-existing-alpine-linux-installation).

### Native Installation On An Existing Alpine Linux Installation

While using the virtualized system is the preferred method due to it creating reproducable and easily distributable installations, it is also possible to set up a native installation.

1. Run `mkdir -p /etc/theia` to create the configuration directory
2. Run `curl -o /etc/theia/packages.txt https://raw.githubusercontent.com/pojntfx/felicitas-pojtingers-theia/master/packages.txt` to download the list of the required packages
3. Run `curl -o /etc/theia/repositories.txt https://raw.githubusercontent.com/pojntfx/felicitas-pojtingers-theia/master/repositories.txt` to download the recommended repositories
4. Run `curl -o /etc/theia/setup.sh https://raw.githubusercontent.com/pojntfx/felicitas-pojtingers-theia/master/setup.sh` to download the installation script
5. Run `sed -i /etc/theia/setup.sh -e 's/ENABLE_OS_SETUP="1"/ENABLE_OS_SETUP="0"/g'` to disable the OS setup steps
6. Adjust the other settings (especially the password) in `/etc/theia/setup.sh` to your liking
7. Setup the repositories by running `cp /etc/theia/repositories.txt /etc/apk/repositories`
8. Install the packages by running `apk add $(cat /etc/theia/packages.txt | sed -e ':a;N;$!ba;s/\n/ /g')`
9. Start the installation by running `sh /etc/theia/setup.sh`
10. Run `rc-service supervisord restart` and continue to [Usage](#usage)

To update the IDE, re-run the steps above (don't forget to adjust your settings).

## Usage

To access the services, use the passwords you've specified in `setup.sh` and the addresses below. The default username is `pojntfx`, the default password is `mysvcpassword`. You'll also have to trust the SSL certificate (see [a video I made on the subject for macOS](https://www.youtube.com/watch?v=_PJc7RcMnw8) and [another one I made for Linux](https://www.youtube.com/watch?v=byFN8vH2SaM)). If you don't use SSH forwarding or are on the machine that runs the IDE, you'll most likely want to replace `localhost` with the IP or domain of the machine that is running the IDE, i.e. `myide.example.com` or `192.168.178.23`.

- wetty: [https://localhost:8000](https://localhost:8000)
- Theia: [https://localhost:8001](https://localhost:8001)
- noVNC: [https://localhost:8002](https://localhost:8002)

Note that Safari is not supported in Theia due to an [issue with WebSockets and HTTP basic auth](https://bugs.webkit.org/show_bug.cgi?id=80362). To use Theia on Safari, open noVNC, add it to the homescreen and use Chromium in noVNC to browse to Theia.

## License

Felicitas Pojtinger's Theia (c) 2020 Felicitas Pojtinger

SPDX-License-Identifier: AGPL-3.0
