#!/bin/bash

# Root script
function as_root() {
    # Install texlive-base, pandoc and jq (for config file editing)
    apt install -y texlive-base pandoc plantuml gnuplot jq
}

# User script
function as_user() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Read versions
    . /opt/pojde/versions.sh

    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the technical documentation extensions
    code-server --force --install-extension 'valentjn.vscode-ltex'
    code-server --force --install-extension 'James-Yu.latex-workshop'
    code-server --force --install-extension 'foam.foam-vscode'
    code-server --force --install-extension 'tchayen.markdown-links'
    code-server --force --install-extension 'yzhang.markdown-all-in-one'
    code-server --force --install-extension 'hediet.vscode-drawio'
    code-server --force --install-extension 'jock.svg'
    code-server --force --install-extension 'cweijan.vscode-office'
    code-server --force --install-extension 'shd101wyy.markdown-preview-enhanced'

    # We are modifying files in the config dir
    CONFIG_DIR=/home/${POJDE_USERNAME}/.local/share/code-server/User/

    # Set the correct shortcuts for markdown preview enhanced
    jq '. += [{"key":"ctrl+shift+v","command":"-markdown.showPreview","when":"!notebookEditorFocused && editorLangId == 'markdown'"}]' ${CONFIG_DIR}/keybindings.json >${CONFIG_DIR}/keybindings.json.tmp && mv ${CONFIG_DIR}/keybindings.json.tmp ${CONFIG_DIR}/keybindings.json
    jq '. += [{"key":"ctrl+shift+v","command":"markdown-preview-enhanced.openPreview","when":"editorLangId == 'markdown'"}]' ${CONFIG_DIR}/keybindings.json >${CONFIG_DIR}/keybindings.json.tmp && mv ${CONFIG_DIR}/keybindings.json.tmp ${CONFIG_DIR}/keybindings.json

    # Add editor associations
    jq '.["workbench.editorAssociations"] = [{"viewType":"cweijan.officeViewer","filenamePattern":"*.pdf"},{"viewType":"default","filenamePattern":"*.md"}]' ${CONFIG_DIR}/settings.json >${CONFIG_DIR}/settings.json.tmp && mv ${CONFIG_DIR}/settings.json.tmp ${CONFIG_DIR}/settings.json
}
