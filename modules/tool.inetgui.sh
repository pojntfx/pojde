#!/bin/bash

# Root script
function as_root() {
    # Install browsers and email tools from Debian repos
    apt install -y chromium firefox-esr epiphany-browser thunderbird
}

# User script
function as_user() {
    :
}
