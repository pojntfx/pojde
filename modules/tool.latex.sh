#!/bin/bash

# Root script
function as_root() {
    # Install texlive-full
    apt install -y texlive-full
}

# User script
function as_user() {
    :
}
