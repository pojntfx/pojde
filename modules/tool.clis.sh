#!/bin/bash

# Root script
function as_root() {
    # Install common CLIs
    apt install -y tmux jq procps tree
}

# User script
function as_user() {
    :
}
