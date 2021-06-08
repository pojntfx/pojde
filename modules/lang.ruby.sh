#!/bin/bash

# Root script
function as_root() {
    # Install Ruby and dependencies
    apt install -y curl make git build-essential gnupg2 procps libtool libffi-dev make libzmq3-dev libczmq-dev libgdbm-dev libncurses-dev libssl-dev libreadline-dev libyaml-dev zlib1g-dev bison

    # Install and activate the Ruby Version Manager
    gpg2 --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3 7D2BAF1CF37B13E2069D6956105BD0E739499BDB
    curl -sSL https://get.rvm.io | bash -s stable
    source /etc/profile.d/rvm.sh

    # Install Ruby version
    rvm install 2.7.1
    rvm use 2.7.1

    # Install Bundler
    gem install bundler --no-ri

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
    . /opt/pojde/preferences/preferences.sh

    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the Ruby VSCode extensions
    code-server --force --install-extension 'rebornix.ruby'
    code-server --force --install-extension 'kaiwood.endwise'
    code-server --force --install-extension 'connorshea.vscode-ruby-test-adapter'

    # Register the Ruby Jupyter kernel
    iruby register --force
}
