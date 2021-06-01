#!/bin/bash

# Upgrade script
function upgrade() {
  # Read configuration file
  . /opt/pojde/preferences/preferences.sh

  # Change the password to the new value
  CONFIG_FILE=/opt/pojde/code-server/code-server.yaml
  cat <<EOT >$CONFIG_FILE
bind-addr: 127.0.0.1:38001
auth: password
password: "${POJDE_PASSWORD}"
EOT

  # Create the config dir
  CONFIG_DIR=/home/${POJDE_USERNAME}/.local/share/code-server/User/
  mkdir -p ${CONFIG_DIR}

  # Add web-optimized shortcuts
  cat <<EOT >${CONFIG_DIR}/keybindings.json
[
  {
    "command": "editor.action.marker.nextInFiles",
    "keybinding": "alt+p",
    "when": "editorFocus && !editorReadonly",
    "resolved": [
      {
        "key": {
          "code": "KeyP",
          "keyCode": 80,
          "easyString": "p"
        },
        "ctrl": false,
        "shift": false,
        "alt": true,
        "meta": false
      }
    ],
    "scope": 1,
    "key": "alt+p"
  },
  {
    "command": "file.rename",
    "keybinding": "alt+r",
    "context": "navigatorActive",
    "resolved": [
      {
        "key": {
          "code": "KeyR",
          "keyCode": 82,
          "easyString": "r"
        },
        "ctrl": false,
        "shift": false,
        "alt": true,
        "meta": false
      }
    ],
    "scope": 1,
    "key": "alt+r"
  },
  {
    "command": "editor.action.rename",
    "keybinding": "alt+r",
    "when": "editorHasRenameProvider && editorTextFocus && !editorReadonly",
    "resolved": [
      {
        "key": {
          "code": "KeyR",
          "keyCode": 82,
          "easyString": "r"
        },
        "ctrl": false,
        "shift": false,
        "alt": true,
        "meta": false
      }
    ],
    "scope": 1,
    "key": "alt+r"
  },
  {
    "command": "editor.action.goToReferences",
    "keybinding": "alt+i",
    "when": "editorHasReferenceProvider && editorTextFocus && !inReferenceSearchEditor && !isInEmbeddedEditor",
    "key": "alt+i"
  },
  {
    "key": "alt+w",
    "command": "workbench.action.closeActiveEditor"
  },
  {
    "key": "shift+alt+p",
    "command": "workbench.action.showCommands"
  },
  {
    "key": "ctrl+shift+\`",
    "command": "workbench.action.terminal.new"
  },
  {
    "key": "alt+t",
    "command": "workbench.action.showAllSymbols"
  },
  {
    "key": "ctrl+enter",
    "command": "workbench.action.debug.start",
    "when": "debuggersAvailable && debugState != 'initializing'"
  }
]
EOT

  # Add web-optimized configuration
  cat <<EOT >${CONFIG_DIR}/settings.json
{
  "editor.autoSave": "on",
  "keyboard.dispatch": "keyCode",
  "sqltools.useNodeRuntime": true,
  "git.pullTags": false,
  "jest.autoEnable": false,
  "markdown-preview-enhanced.previewTheme": "none.css",
  "omnisharp.enableImportCompletion": true,
  "omnisharp.organizeImportsOnFormat": true,
  "omnisharp.enableRoslynAnalyzers": true,
  "[jsonc]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescriptreact]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[html]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[typescript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[yaml]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[json]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "[markdown]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  }
}
EOT

  # Fix permissions for user
  chown -R ${POJDE_USERNAME} /home/${POJDE_USERNAME}/.local/

  # Enable & restart the services
  if [ "${POJDE_OPENRC}" = 'true' ]; then
    rc-service code-server restart
    rc-update add code-server default
  else
    systemctl enable "code-server@${POJDE_USERNAME}"
    systemctl restart "code-server@${POJDE_USERNAME}"
  fi
}

# Refresh script
function refresh() {
  # Read configuration file
  . /opt/pojde/preferences/preferences.sh

  # Remove extensions
  rm -rf /home/${POJDE_USERNAME}/.local/share/code-server/extensions/*
}
