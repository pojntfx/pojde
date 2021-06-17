#!/bin/bash

# Upgrade script
function upgrade() {
    # Read configuration file
    . /opt/pojde/preferences/preferences.sh

    # Services to enable/disable
    services_to_enable=()
    services_to_disable=()

    # Cockpit
    group_services=(
        "cockpit.socket"
    )
    if [ "${POJDE_OPENRC}" = 'true' ]; then
        group_services=() # Not available on OpenRC
    fi
    if [ "${POJDE_SERVICE_COCKPIT_ENABLED}" = "true" ]; then
        services_to_enable+=("${group_services[@]}")
    else
        services_to_disable+=("${group_services[@]}")
    fi

    # code-server
    group_services=(
        "code-server@${POJDE_USERNAME}"
    )
    if [ "${POJDE_OPENRC}" = 'true' ]; then
        group_services=(
            "code-server"
        )
    fi
    if [ "${POJDE_SERVICE_CODESERVER_ENABLED}" = "true" ]; then
        services_to_enable+=("${group_services[@]}")
    else
        services_to_disable+=("${group_services[@]}")
    fi

    # ttyd
    group_services=(
        "ttyd@${POJDE_USERNAME}"
    )
    if [ "${POJDE_OPENRC}" = 'true' ]; then
        group_services=(
            "ttyd"
        )
    fi
    if [ "${POJDE_SERVICE_TTYD_ENABLED}" = "true" ]; then
        services_to_enable+=("${group_services[@]}")
    else
        services_to_disable+=("${group_services[@]}")
    fi

    # noVNC
    group_services=(
        "xvfb@${POJDE_USERNAME}"
        "desktop@${POJDE_USERNAME}"
        "x11vnc@${POJDE_USERNAME}"
        "novnc@${POJDE_USERNAME}"
    )
    if [ "${POJDE_OPENRC}" = 'true' ]; then
        group_services=(
            "xvfb"
            "desktop"
            "x11vnc"
            "novnc"
        )
    fi
    if [ "${POJDE_SERVICE_NOVNC_ENABLED}" = "true" ]; then
        services_to_enable+=("${group_services[@]}")
    else
        services_to_disable+=("${group_services[@]}")
    fi

    # JupyterLab
    group_services=(
        "jupyter-lab@${POJDE_USERNAME}"
    )
    if [ "${POJDE_OPENRC}" = 'true' ]; then
        group_services=(
            "jupyter-lab"
        )
    fi
    if [ "${POJDE_SERVICE_JUPYTERLAB_ENABLED}" = "true" ]; then
        services_to_enable+=("${group_services[@]}")
    else
        services_to_disable+=("${group_services[@]}")
    fi

    # Enable/disable services specified
    if [ "${POJDE_OPENRC}" = 'true' ]; then
        for service in "${services_to_enable[@]}"; do
            rc-update add "${service}" default
            rc-service "${service}" restart
        done

        for service in "${services_to_disable[@]}"; do
            rc-service "${service}" stop
            rc-update delete "${service}" default
        done
    else
        for service in "${services_to_enable[@]}"; do
            systemctl enable "${service}"
            systemctl restart "${service}"
        done

        for service in "${services_to_disable[@]}"; do
            systemctl disable --now "${service}"
        done
    fi
}

# Refresh script
function refresh() {
    :
}
