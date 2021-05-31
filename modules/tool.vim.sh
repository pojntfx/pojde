#!/bin/bash

# Root script
function as_root() {
    :
}

# User script
function as_user() {
    # Install the VSCodeVim VSCode extension
    # We have do download manually due to https://github.com/cdr/code-server/pull/2659#issuecomment-780147098
    VERSION="${VIM_EXTENSION_VERSION}"
    FILE=/tmp/vim.vsix
    curl -L -o ${FILE} https://open-vsx.org/api/vscodevim/vim/${VERSION}/file/vscodevim.vim-${VERSION}.vsix
    code-server --force --install-extension ${FILE}
    rm ${FILE}
}
