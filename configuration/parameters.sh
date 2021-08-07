#!/bin/bash

# Section title
SECTION_TITLE="pojde Configuration"

# Display welcome message
dialog --backtitle "${SECTION_TITLE}" --msgbox "Welcome to pojde! Please press ENTER to start the configuration process." 0 0

# Create preferences directory and preference file
PREFERENCE_FILE="/opt/pojde/preferences/preferences.sh"
TMP_PREFERENCE_FILE="${PREFERENCE_FILE}.tmp"
touch ${PREFERENCE_FILE}
touch ${TMP_PREFERENCE_FILE}

# If the preferences exist, . them
. ${PREFERENCE_FILE}

input_required() {
    key="${1}"
    prompt="${2}"
    error_message="${3}"
    boxtype="${4}"

    input=""
    while [ "${input}" = "" ]; do
        input=$(dialog --backtitle "${SECTION_TITLE}" --stdout --nocancel --insecure --${boxtype} "${prompt}" 0 0 "${!key}")

        if [ "${input}" = "" ]; then
            dialog --backtitle "${SECTION_TITLE}" --msgbox "${error_message}" 0 0

            continue
        fi

        echo export "${key}"="'""${input}""'" >>${TMP_PREFERENCE_FILE}
    done
}

input_required_confirmed() {
    key_1="${1}"
    key_2="${2}"
    prompt_1="${3}"
    prompt_2="${4}"
    error_message_1="${5}"
    error_message_2="${6}"
    retry_message="${7}"
    boxtype="${8}"

    while :; do
        input_required "${key_1}" "${prompt_1}" "${error_message_1}" "${boxtype}"
        new_value="${input}" # From input_required
        input_required "${key_2}" "${prompt_2}" "${error_message_2}" "${boxtype}"
        confirmed_new_value="${input}" # From input_required

        if [ "${new_value}" = "${confirmed_new_value}" ]; then
            break
        fi

        dialog --backtitle "${SECTION_TITLE}" --msgbox "${retry_message}" 0 0
    done
}

# New root password
input_required_confirmed \
    "POJDE_ROOT_PASSWORD" "POJDE_ROOT_PASSWORD_CONFIRMATION" \
    "New root password:" "Confirm new root password:" \
    "Please enter a non-empty root password." "Please enter the root password." \
    "The two passwords don't match, please try again." \
    "passwordbox"

# New username and password
input_required "POJDE_USERNAME" "New user's username:" "Please enter a non-empty username." "inputbox"
input_required_confirmed \
    "POJDE_PASSWORD" "POJDE_PASSWORD_CONFIRMATION" \
    "New user's password:" "Confirm new password:" \
    "Please enter a non-empty password." "Please enter the password." \
    "The two passwords don't match, please try again." \
    "passwordbox"

# Email and full name address (for Git)
input_required "POJDE_EMAIL" "Your email address (for Git):" "Please enter a valid email address." "inputbox"
input_required "POJDE_FULL_NAME" "Your full name (for Git):" "Please enter a valid name." "inputbox"

# IP and domain
input_required "POJDE_IP" "IP address of this host (this has to be the valid IP address, or HTTPS will not work on this IP):" "Please enter a valid IP address." "inputbox"
input_required "POJDE_DOMAIN" "Domain of this host (this has to be the valid domain, or HTTPS will not work on this domain):" "Please enter a valid domain." "inputbox"

# Ask for SSH key URL; get from GitHub by default
if [ -z "${POJDE_SSH_KEY_URL}" ]; then
    . ${TMP_PREFERENCE_FILE} # In case the user has changed their username, reload it

    export POJDE_SSH_KEY_URL="https://github.com/${POJDE_USERNAME}.keys"
fi
input_required "POJDE_SSH_KEY_URL" "Link to your SSH keys (this has to be a valid URL to your SSH keys, or SSH will not work):" "Please enter a valid URL." "inputbox"

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
selected_modules="$(dialog --backtitle "${SECTION_TITLE}" --stdout --nocancel --checklist "Additional modules to install:" 0 0 0 "${available_modules[@]}") "

# Persist checklist state
echo export POJDE_MODULE_CCPP_ENABLED="'""$([[ "$selected_modules" == *"lang.ccpp "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_GO_ENABLED="'""$([[ "$selected_modules" == *"lang.go "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_PYTHON_ENABLED="'""$([[ "$selected_modules" == *"lang.python "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_RUST_ENABLED="'""$([[ "$selected_modules" == *"lang.rust "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_JAVASCRIPT_ENABLED="'""$([[ "$selected_modules" == *"lang.javascript "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_RUBY_ENABLED="'""$([[ "$selected_modules" == *"lang.ruby "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_CSHARP_ENABLED="'""$([[ "$selected_modules" == *"lang.csharp "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_JAVA_ENABLED="'""$([[ "$selected_modules" == *"lang.java "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_JULIA_ENABLED="'""$([[ "$selected_modules" == *"lang.julia "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_OCTAVE_ENABLED="'""$([[ "$selected_modules" == *"lang.octave "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_R_ENABLED="'""$([[ "$selected_modules" == *"lang.r "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_SQL_ENABLED="'""$([[ "$selected_modules" == *"lang.sql "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_BASH_ENABLED="'""$([[ "$selected_modules" == *"lang.bash "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_VIM_ENABLED="'""$([[ "$selected_modules" == *"tool.vim "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_DEVOPS_ENABLED="'""$([[ "$selected_modules" == *"tool.devops "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_TECHDOCS_ENABLED="'""$([[ "$selected_modules" == *"tool.techdocs "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_LATEX_ENABLED="'""$([[ "$selected_modules" == *"tool.latex "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_WEBDEV_ENABLED="'""$([[ "$selected_modules" == *"tool.webdev "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_EXTENSIONS_ENABLED="'""$([[ "$selected_modules" == *"tool.extensions "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_CLIS_ENABLED="'""$([[ "$selected_modules" == *"tool.clis "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_NETWORKING_ENABLED="'""$([[ "$selected_modules" == *"tool.networking "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_INETTUI_ENABLED="'""$([[ "$selected_modules" == *"tool.inettui "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_INETGUI_ENABLED="'""$([[ "$selected_modules" == *"tool.inetgui "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_MODULE_MULTIMEDIA_ENABLED="'""$([[ "$selected_modules" == *"tool.multimedia "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}

# Persist checklist selection
echo export "POJDE_MODULES=\"${selected_modules}\"" >>${TMP_PREFERENCE_FILE}

# Ask for service customization
available_services=(
    cockpit "Cockpit (general management interface)" $([ "${POJDE_SERVICE_COCKPIT_ENABLED}" = "true" ] && echo on || echo off)
    codeserver "code-server (VSCode in the browser)" $([ "${POJDE_SERVICE_CODESERVER_ENABLED}" = "true" ] && echo on || echo off)
    ttyd "ttyd (shell access from the browser)" $([ "${POJDE_SERVICE_TTYD_ENABLED}" = "true" ] && echo on || echo off)
    novnc "noVNC (graphical access from the browser)" $([ "${POJDE_SERVICE_NOVNC_ENABLED}" = "true" ] && echo on || echo off)
    jupyterlab "JupyterLab (interactive development environment)" $([ "${POJDE_SERVICE_JUPYTERLAB_ENABLED}" = "true" ] && echo on || echo off)
)
selected_services="$(dialog --backtitle "${SECTION_TITLE}" --stdout --nocancel --checklist "Services to enable:" 0 0 0 "${available_services[@]}") "

# Persist checklist state
echo export POJDE_SERVICE_COCKPIT_ENABLED="'""$([[ "$selected_services" == *"cockpit "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_SERVICE_CODESERVER_ENABLED="'""$([[ "$selected_services" == *"codeserver "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_SERVICE_TTYD_ENABLED="'""$([[ "$selected_services" == *"ttyd "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_SERVICE_NOVNC_ENABLED="'""$([[ "$selected_services" == *"novnc "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}
echo export POJDE_SERVICE_JUPYTERLAB_ENABLED="'""$([[ "$selected_services" == *"jupyterlab "* ]] && echo true || echo false)""'" >>${TMP_PREFERENCE_FILE}

# Persist checklist selection
echo export "POJDE_SERVICES=\"${selected_services}\"" >>${TMP_PREFERENCE_FILE}

# Ask for confirmation
dialog --backtitle "${SECTION_TITLE}" --yesno 'Are you sure you want apply the configuration?' 0 0 || exit 1

# Write to configuration file if accepted
mv ${TMP_PREFERENCE_FILE} ${PREFERENCE_FILE}

# Continue with the next scripts
exit 0
