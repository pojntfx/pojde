#!/bin/bash

# Display welcome message
dialog --msgbox "Welcome to pojde! Please press ENTER to start the configuration process." 0 0

# Create preferences directory and preference file
PREFERENCE_FILE="/opt/pojde/preferences/preferences.sh"
TMP_PREFERENCE_FILE="${PREFERENCE_FILE}.tmp"
touch ${PREFERENCE_FILE}
touch ${TMP_PREFERENCE_FILE}

# If the preferences exist, . them
. ${PREFERENCE_FILE}

# Ask for new root password
echo export "'"POJDE_ROOT_PASSWORD="$(dialog --stdout --nocancel --insecure --passwordbox "New root password:" 0 0 ${POJDE_ROOT_PASSWORD})""'" >${TMP_PREFERENCE_FILE}

# Ask for new username and password
echo export "'"POJDE_USERNAME="$(dialog --stdout --nocancel --inputbox "New user's username:" 0 0 ${POJDE_USERNAME})""'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_PASSWORD="$(dialog --stdout --nocancel --insecure --passwordbox "New user's password:" 0 0 ${POJDE_PASSWORD})""'" >>${TMP_PREFERENCE_FILE}

# Ask for email and full name address (for Git)
echo export "'"POJDE_EMAIL="$(dialog --stdout --nocancel --insecure --inputbox "Your email address (for Git):" 0 0 ${POJDE_EMAIL})""'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_FULL_NAME="$(dialog --stdout --nocancel --insecure --inputbox "Your full name (for Git):" 0 0 "${POJDE_FULL_NAME}")""'" >>${TMP_PREFERENCE_FILE}

# Ask for IP domain
echo export "'"POJDE_IP="$(dialog --stdout --nocancel --inputbox "IP address of this host:" 0 0 ${POJDE_IP})""'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_DOMAIN="$(dialog --stdout --nocancel --inputbox "Domain of this host:" 0 0 ${POJDE_DOMAIN})""'" >>${TMP_PREFERENCE_FILE}

# Ask for SSH key URL; get from GitHub by default
if [ -z "${POJDE_SSH_KEY_URL}" ]; then
    . ${TMP_PREFERENCE_FILE} # In case the user has changed their username, reload it

    export POJDE_SSH_KEY_URL="https://github.com/${POJDE_USERNAME}.keys"
fi
echo export "'"POJDE_SSH_KEY_URL="$(dialog --stdout --nocancel --inputbox "Link to your SSH keys:" 0 0 ${POJDE_SSH_KEY_URL})""'" >>${TMP_PREFERENCE_FILE}

# Ask for module customization
available_modules=(
    lang.ccpp C/C++ $([ "${POJDE_MODULE_CCPP_ENABLED}" = "true" ] && echo on || echo off)
    lang.go Go $([ "${POJDE_MODULE_GO_ENABLED}" = "true" ] && echo on || echo off)
    lang.python Python $([ "${POJDE_MODULE_PYTHON_ENABLED}" = "true" ] && echo on || echo off)
    lang.rust Rust $([ "${POJDE_MODULE_RUST_ENABLED}" = "true" ] && echo on || echo off)
    lang.javascript JavaScript $([ "${POJDE_MODULE_JAVASCRIPT_ENABLED}" = "true" ] && echo on || echo off)
    lang.ruby Ruby $([ "${POJDE_MODULE_RUBY_ENABLED}" = "true" ] && echo on || echo off)
    lang.csharp C# $([ "${POJDE_MODULE_CSHARP_ENABLED}" = "true" ] && echo on || echo off)
    lang.java Java $([ "${POJDE_MODULE_JAVA_ENABLED}" = "true" ] && echo on || echo off)
    lang.julia Julia $([ "${POJDE_MODULE_JULIA_ENABLED}" = "true" ] && echo on || echo off)
    lang.octave Octave $([ "${POJDE_MODULE_OCTAVE_ENABLED}" = "true" ] && echo on || echo off)
    lang.r R $([ "${POJDE_MODULE_R_ENABLED}" = "true" ] && echo on || echo off)
    lang.sql SQL $([ "${POJDE_MODULE_SQL_ENABLED}" = "true" ] && echo on || echo off)
    lang.bash Bash $([ "${POJDE_MODULE_BASH_ENABLED}" = "true" ] && echo on || echo off)
    tool.vim Vim $([ "${POJDE_MODULE_VIM_ENABLED}" = "true" ] && echo on || echo off)
    tool.devops "QEMU, Docker and Kubernetes" $([ "${POJDE_MODULE_DEVOPS_ENABLED}" = "true" ] && echo on || echo off)
    tool.techdocs "Technical Documentation" $([ "${POJDE_MODULE_TECHDOCS_ENABLED}" = "true" ] && echo on || echo off)
    tool.latex "Full LaTeX Support" $([ "${POJDE_MODULE_LATEX_ENABLED}" = "true" ] && echo on || echo off)
    tool.webdev "Web Development" $([ "${POJDE_MODULE_WEBDEV_ENABLED}" = "true" ] && echo on || echo off)
    tool.extensions "Common VSCode Extensions" $([ "${POJDE_MODULE_EXTENSIONS_ENABLED}" = "true" ] && echo on || echo off)
    tool.clis "Common CLIs" $([ "${POJDE_MODULE_CLIS_ENABLED}" = "true" ] && echo on || echo off)
    tool.networking Networking $([ "${POJDE_MODULE_NETWORKING_ENABLED}" = "true" ] && echo on || echo off)
    tool.inettui "Browsers and Mail (TUI)" $([ "${POJDE_MODULE_INETTUI_ENABLED}" = "true" ] && echo on || echo off)
    tool.inetgui "Browsers and Mail (GUI)" $([ "${POJDE_MODULE_INETGUI_ENABLED}" = "true" ] && echo on || echo off)
    tool.multimedia Multimedia $([ "${POJDE_MODULE_MULTIMEDIA_ENABLED}" = "true" ] && echo on || echo off)
)
selected_modules="$(dialog --stdout --nocancel --checklist "Additional modules to install:" 0 0 0 "${available_modules[@]}") "

# Persist checklist state
echo export "'"POJDE_MODULE_CCPP_ENABLED=$([[ "$selected_modules" == *"lang.ccpp "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_GO_ENABLED=$([[ "$selected_modules" == *"lang.go "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_PYTHON_ENABLED=$([[ "$selected_modules" == *"lang.python "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_RUST_ENABLED=$([[ "$selected_modules" == *"lang.rust "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_JAVASCRIPT_ENABLED=$([[ "$selected_modules" == *"lang.javascript "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_RUBY_ENABLED=$([[ "$selected_modules" == *"lang.ruby "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_CSHARP_ENABLED=$([[ "$selected_modules" == *"lang.csharp "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_JAVA_ENABLED=$([[ "$selected_modules" == *"lang.java "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_JULIA_ENABLED=$([[ "$selected_modules" == *"lang.julia "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_OCTAVE_ENABLED=$([[ "$selected_modules" == *"lang.octave "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_R_ENABLED=$([[ "$selected_modules" == *"lang.r "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_SQL_ENABLED=$([[ "$selected_modules" == *"lang.sql "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_BASH_ENABLED=$([[ "$selected_modules" == *"lang.bash "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_VIM_ENABLED=$([[ "$selected_modules" == *"tool.vim "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_DEVOPS_ENABLED=$([[ "$selected_modules" == *"tool.devops "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_TECHDOCS_ENABLED=$([[ "$selected_modules" == *"tool.techdocs "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_LATEX_ENABLED=$([[ "$selected_modules" == *"tool.latex "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_WEBDEV_ENABLED=$([[ "$selected_modules" == *"tool.webdev "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_EXTENSIONS_ENABLED=$([[ "$selected_modules" == *"tool.extensions "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_CLIS_ENABLED=$([[ "$selected_modules" == *"tool.clis "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_NETWORKING_ENABLED=$([[ "$selected_modules" == *"tool.networking "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_INETTUI_ENABLED=$([[ "$selected_modules" == *"tool.inettui "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_INETGUI_ENABLED=$([[ "$selected_modules" == *"tool.inetgui "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}
echo export "'"POJDE_MODULE_MULTIMEDIA_ENABLED=$([[ "$selected_modules" == *"tool.multimedia "* ]] && echo true || echo false)"'" >>${TMP_PREFERENCE_FILE}

# Persist checklist selection
echo export "'"POJDE_MODULES=${selected_modules}"'" >>${TMP_PREFERENCE_FILE}

# Ask for confirmation
dialog --yesno 'Are you sure you want apply the configuration?' 0 0 || exit 1

# Write to configuration file if accepted
mv ${TMP_PREFERENCE_FILE} ${PREFERENCE_FILE}

# Continue with the next scripts
exit 0
