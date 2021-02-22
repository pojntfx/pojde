# pojde Next Generation

## Goals

Headless development environment with web access for all components.

- <5 Minutes installation time
- <3 GB installation size
- Based on Debian
- Graphical customization
- Languages (toolchain, VSCode extensions and Jupyter Lab) should be configurable
- Tools (browsers, file sharing etc.) should be configurable

## Management

`pojdectl` is the new management tool.

- `build` builds the image
- `apply` starts or creates the container, reads the parameters if they exist, asks for parameters, persists & applies the parameters, and restarts the container
- `start` starts the container
- `stop` stops the container
- `restart` restarts the container
- `remove` removes the container
- `logs` shows the system logs
- `enter` opens a shell

## Build

- Install common repositories & upgrade system
- Install common packages

- Install & configure cockpit
  - Change port
- Install & configure code-server
  - Change port
- Install & configure ttyd
  - Change port
- Install & configure noVNC
  - Change port
- Install & configure Jupyter Lab
  - Change port
- Install & configure nginx
  - Add sites
- Install & configure SSH
  - Enable TCP forwarding

## Parameters (with `dialog`)

- Root password
- Username & password
- Domain
- GitHub username

## Configuration

- Customize system
  - Set root password
  - Create user in wheel group with username & password
- Customize code-server
  - Set username & password
- Customize ttyd
  - Set username & password
- Customize noVNC
  - Set password
- Customize Jupyter Lab
  - Set password
- Customize nginx
  - Setup certificates for domain
- Customize SSH
  - Fetch keys from GitHub into authorized_keys
