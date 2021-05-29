#!/bin/bash

# Root script
function as_root() {
    # Install SQLite, MariaDB client and PostgreSQL client
    apt install -y sqlite3 mariadb-client postgresql-client

    # Install Node (required for the drivers)
    curl -fsSL https://deb.nodesource.com/setup_14.x | bash -
    apt install -y nodejs build-essential

    # Download the SQL Jupyter Kernel on x86_64 (see https://github.com/pojntfx/xeus-sql-binaries#installation)
    if [ "$(uname -m)" = 'x86_64' ]; then
        # Fetch the xeus-sql binary package
        curl -L -o /tmp/xeus-sql.tar.gz https://github.com/pojntfx/xeus-sql-binaries/releases/download/latest/xeus-sql.$(uname -m).tar.gz

        # Extract the package to /usr/local/xeus-sql
        XEUS_PREFIX=/usr/local/xeus-sql
        mkdir -p ${XEUS_PREFIX}
        tar -C ${XEUS_PREFIX} -xzf /tmp/xeus-sql.tar.gz
        rm /tmp/xeus-sql.tar.gz

        # Install the kernel
        jupyter kernelspec install ${XEUS_PREFIX}/share/jupyter/kernels/xsql --sys-prefix
    fi
}

# User script
function as_user() {
    # Read versions
    . /opt/pojde/versions.sh

    # We'll use Open-VSX
    export SERVICE_URL=https://open-vsx.org/vscode/gallery
    export ITEM_URL=https://open-vsx.org/vscode/item

    # Install the SQL VSCode extensions
    VERSION="${SQLTOOLS_EXTENSION_VERSION}"
    FILE=/tmp/sqltools.vsix
    curl --compressed -L -o ${FILE} https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools/${VERSION}/vspackage
    code-server --force --install-extension ${FILE}
    rm ${FILE}

    VERSION="${SQLTOOLS_EXTENSION_SQLITE_VERSION}"
    FILE=/tmp/sqltools-driver-sqlite.vsix
    curl --compressed -L -o ${FILE} https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-sqlite/${VERSION}/vspackage
    code-server --force --install-extension ${FILE}
    rm ${FILE}

    VERSION="${SQLTOOLS_EXTENSION_MYSQL_VERSION}"
    FILE=/tmp/sqltools-driver-mysql.vsix
    curl --compressed -L -o ${FILE} https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-mysql/${VERSION}/vspackage
    code-server --force --install-extension ${FILE}
    rm ${FILE}

    VERSION="${SQLTOOLS_EXTENSION_PG_VERSION}"
    FILE=/tmp/sqltools-driver-pg.vsix
    curl --compressed -L -o ${FILE} https://marketplace.visualstudio.com/_apis/public/gallery/publishers/mtxr/vsextensions/sqltools-driver-pg/${VERSION}/vspackage
    code-server --force --install-extension ${FILE}
    rm ${FILE}
}
