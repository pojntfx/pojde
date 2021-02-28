#!/bin/bash

# Upgrade script
function upgrade() {
  # Read configuration file
  . /opt/pojde-ng/preferences/preferences.sh

  # Change the password to the new value
  CONFIG_FILE=/opt/pojde-ng/code-server/code-server.yaml
  cat <<EOT >$CONFIG_FILE
bind-addr: 127.0.0.1:38001
auth: password
password: "${POJDE_NG_PASSWORD}"
EOT

  # Create the config dir
  CONFIG_DIR=/home/${POJDE_NG_USERNAME}/.local/share/code-server/User/
  mkdir -p ${CONFIG_DIR}

  # Add web-optimized shortcuts
  cat <<EOT >${CONFIG_DIR}/keybindings.json
[
  {
    "command": "-editor.action.marker.nextInFiles",
    "keybinding": "f8",
    "when": "editorFocus && !editorReadonly",
    "resolved": [
      {
        "key": {
          "code": "F8",
          "keyCode": 119,
          "easyString": "f8"
        },
        "ctrl": false,
        "shift": false,
        "alt": false,
        "meta": false
      }
    ],
    "scope": 1,
    "key": "f8"
  },
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
    "command": "-file.rename",
    "keybinding": "f2",
    "context": "navigatorActive",
    "resolved": [
      {
        "key": {
          "code": "F2",
          "keyCode": 113,
          "easyString": "f2"
        },
        "ctrl": false,
        "shift": false,
        "alt": false,
        "meta": false
      }
    ],
    "scope": 1,
    "key": "f2"
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
    "command": "-editor.action.rename",
    "keybinding": "f2",
    "when": "editorHasRenameProvider && editorTextFocus && !editorReadonly",
    "resolved": [
      {
        "key": {
          "code": "F2",
          "keyCode": 113,
          "easyString": "f2"
        },
        "ctrl": false,
        "shift": false,
        "alt": false,
        "meta": false
      }
    ],
    "scope": 1,
    "key": "f2"
  },
  {
    "command": "editor.action.goToReferences",
    "keybinding": "alt+i",
    "when": "editorHasReferenceProvider && editorTextFocus && !inReferenceSearchEditor && !isInEmbeddedEditor",
    "key": "alt+i"
  },
  {
    "command": "-editor.action.goToReferences",
    "keybinding": "shift+f12",
    "when": "editorHasReferenceProvider && editorTextFocus && !inReferenceSearchEditor && !isInEmbeddedEditor",
    "key": "shift+f12"
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
    "key": "f1",
    "command": "-workbench.action.showCommands"
  },
  {
    "key": "ctrl+shift+\`",
    "command": "workbench.action.terminal.new"
  },
  {
    "key": "ctrl+shift+c",
    "command": "-workbench.action.terminal.new"
  }
]
EOT

  # Add web-optimized configuration
  cat <<EOT >${CONFIG_DIR}/settings.json
{
  "editor.autoSave": "on",
  "keyboard.dispatch": "keyCode",
  "sqltools.useNodeRuntime": true
}
EOT

  # Fix permissions for user
  chown -R ${POJDE_NG_USERNAME} /home/${POJDE_NG_USERNAME}/.local/

  # Enable & restart the services
  if [ "${POJDE_NG_OPENRC}" = 'true' ]; then
    rc-service code-server restart
    rc-update add code-server default
  else
    systemctl enable "code-server@${POJDE_NG_USERNAME}"
    systemctl restart "code-server@${POJDE_NG_USERNAME}"
  fi
}

# Refresh script
function refresh() {
  # Read configuration file
  . /opt/pojde-ng/preferences/preferences.sh

  # Remove extensions
  rm -rf /home/${POJDE_NG_USERNAME}/.local/share/code-server/extensions/*
}
