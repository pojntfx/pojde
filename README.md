# pojde Next Generation

[![Docker CI](https://github.com/pojntfx/pojde-ng/actions/workflows/docker.yaml/badge.svg)](https://github.com/pojntfx/pojde-ng/actions/workflows/docker.yaml)

## Overview

🚧 This project is WIP. Please use the [original pojde](https://github.com/pojntfx/pojde) until this reaches a stable level. While it has reached feature parity, documentation needs improvement. 🚧

`pojde-ng` is a headless development environment with web access for all components, which can be installed, configured and managed using `pojdectl-ng`, it's management tool.

- Based on Debian
- Interactive configuration
- Monolithic base image with optional modules for programming languages (and their VSCode/Jupyter Lab extensions), browsers, CLIs etc.
- <1 GB base image size (<3 minutes to download on DSL or <15 seconds to download on Gigabit)
- <1 minute installation time
- Runs on both `amd64` and `arm64` processors
- Includes multiple services; see [Usage](#usage)

## Installation

First, [install Docker](https://docs.docker.com/get-docker/). Afterwards, paste the following into your terminal to add `pojdectl-ng` to your `PATH`:

```shell
curl https://raw.githubusercontent.com/pojntfx/pojde-ng/main/bin/pojdectl-ng | bash -s -- upgrade-pojdectl-ng
```

Next, paste the following and follow the instructions:

```shell
pojdectl-ng apply my-pojde-ng 18000
```

Works on Linux, macOS and Windows (through WSL).

## Usage

After [installation](#Installation), the following services should be available:

- [Cockpit](https://cockpit-project.org/), a general management interface for pojde and the container. Disabled if on host system without systemd.
- [code-server](https://github.com/cdr/code-server), VSCode in the browser
- [ttyd](https://tsl0922.github.io/ttyd/), which gives you shell access to pojde
- [noVNC](https://novnc.com/info.html), which gives you graphical access to pojde
- [Jupyter Lab](http://jupyterlab.io/), an interactive development environment

Before accessing them, add the CA certificate to your system; we've created video tutorials for it. The interactive configuration should have prompted you to download yours; you can re-download it by running the `pojdectl-ng apply` command from above again:

- [Trusting self-signed SSL certificates (Chrome on Linux)](https://www.youtube.com/watch?v=byFN8vH2SaM)
- [Trusting self-signed SSL certificates (Chrome on macOS)](https://www.youtube.com/watch?v=_PJc7RcMnw8)
- [Trusting self signed SSL certificates (Chrome on Windows)](https://www.youtube.com/watch?v=gyQ9IIxE3vc)

After adding the CA certificate, you can access the services at the following addresses; substitute `MY_IP` with your chosen domain or IP address:

| Service     | Address               |
| ----------- | --------------------- |
| Cockpit     | `https://MY_IP:18000` |
| code-server | `https://MY_IP:18001` |
| ttyd        | `https://MY_IP:18002` |
| noVNC       | `https://MY_IP:18003` |
| Jupyter Lab | `https://MY_IP:18004` |

Additionally, a SSH server is running inside the container; you can SSH into the container like so:

```shell
$ ssh -p 18022 root@MY_IP
```

> Can't access via SSH? Try again with `ssh -oPubkeyAcceptedKeyTypes=+rsa-sha2-512` (see [this issue](https://bugzilla.redhat.com/show_bug.cgi?id=1881301) for more details).

## Command Reference

```shell
$ pojdectl-ng --help
pojdectl-ng is the management tool for pojde-ng.

Modification Commands:
apply <name> <startPort>            Create or upgrade an instance.
    [-f]orce                            Skip confirmation prompts.
    [-u]pgrade                          Pull latest image.
    [-r]recreate                        Re-create the container.
remove [name...]                    Remove instances(s).
    [-f]orce                            Skip confirmation prompts.
    [-c]ustomization                    Remove customizations.
    [-p]references                      Remove preferences.
    [-s]ecurity                         Remove CA.
    [-u]ser data                        Remove user data.
    [-d]eb cache                        Remove .deb cache.
    [-a]ll                              Remove everything.
list                                List all instances.

Lifecycle Commands:
start [name...]                     Start instance(s).
stop [name...]                      Stop instance(s).
restart [name...]                   Restart instance(s).

Utility Commands:
logs <name>                         Get the logs of an instance.
enter <name>                        Get a shell in an instance.
forward <name> [local:remote...]    Forward port(s) from an instance.

Miscellaneous Commands:
upgrade-pojdectl-ng                 Upgrade this tool.
reset-ca [-f]orce                   Reset the CA.

For more information, please visit https://github.com/pojntfx/pojde-ng#Usage.
```

## License

pojde Next Generation (c) 2021 Felicitas Pojtinger and contributors

SPDX-License-Identifier: AGPL-3.0
