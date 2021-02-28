#!/bin/bash

# Root script
function as_root() {
    # Add the R repository
    apt-key adv --keyserver keys.gnupg.net --recv-key 'E19F5F87128899B192B1A2C2AD5F960A256A04AF'
    echo 'deb http://cloud.r-project.org/bin/linux/debian buster-cran35/' >/etc/apt/sources.list.d/r.list

    # Install R
    apt update
    apt install -y r-base libssl-dev libxml2-dev libcurl4-openssl-dev

    # Install the R language server and R Jupyter Kernel (see https://github.com/IRkernel/IRkernel#installation)
    R -e 'install.packages(c("languageserver", "IRkernel", "R6", "jsonlite", "devtools"), repos="https://cloud.r-project.org")'

    # Download the R debugger
    R -e 'library(devtools); install_github("ManuelHentschel/vscDebugger")'
}

# User script
function as_user() {
    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install R extensions
    code-server --force --install-extension 'Ikuyadeu.r'
    code-server --force --install-extension 'REditorSupport.r-lsp'
    code-server --force --install-extension 'RDebugger.r-debugger'

    # Register the R Jupyter Kernel
    R -e 'IRkernel::installspec()'
}
