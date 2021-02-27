#!/bin/bash

# Root script
function as_root() {
    # Install Ruby and dependencies
    apt install -y ruby-full libtool libffi-dev ruby-dev make libzmq3-dev libczmq-dev

    # Install the Ruby debugger
    gem install rake
    gem install ruby-debug-ide

    # Install Ruby Jupyter kernel (see https://github.com/SciRuby/iruby#ubuntu-17)
    gem install ffi-rzmq
    gem install iruby --pre
}

# User script
function as_user() {
    # Read configuration file
    . /opt/pojde-ng/preferences/preferences.sh

    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the Ruby VSCode extensions
    code-server --force --install-extension 'rebornix.ruby'
    code-server --force --install-extension 'kaiwood.endwise'

    # Register the Ruby Jupyter kernel
    iruby register --force
}
