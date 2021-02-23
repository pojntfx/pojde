# pojde Next Generation

[![Docker CI](https://github.com/pojntfx/pojde-ng/actions/workflows/docker.yaml/badge.svg)](https://github.com/pojntfx/pojde-ng/actions/workflows/docker.yaml)

## Goals

🚧 This project is a WIP. Please use the [original pojde](https://github.com/pojntfx/pojde) until it reaches a stable level. 🚧

Headless development environment with web access for all components.

- Based on Debian
- Interactive configuration
- Languages (toolchain, VSCode & Jupyter Lab extensions) are configurable
- Tools (browsers, CLIs etc.) are configurable
- <1 GB base image size (<3 minutes to download on DSL or <15 seconds to download on Gigabit)
- <1 minute installation time
- Runs on both `amd64` and `arm64`

## Management

`pojdectl` is the new management tool.

- `apply` starts or creates the container, interactively configures it, and restarts it's services
- `start` starts the container
- `stop` stops the container
- `restart` restarts the container
- `remove` removes the container
- `purge` removes the container and the volumes
- `logs` shows the system logs
- `enter` opens a shell in the container

## License

pojde Next Generation (c) 2021 Felicitas Pojtinger and contributors

SPDX-License-Identifier: AGPL-3.0
