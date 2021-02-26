#!/bin/bash

# Upgrade script
function upgrade() {
    # Read configuration file
    . /opt/pojde-ng/preferences/preferences.sh

    # Persist CA in volume and certs in nginx's directory
    OUT_DIR=/etc/nginx
    CONFIG_DIR=/opt/pojde-ng/ca

    # Only generate the CA once
    RAN_FILE=${CONFIG_DIR}/ran
    if [ ! -f ${RAN_FILE} ]; then
        # Generate root CA
        openssl genrsa -out ${CONFIG_DIR}/ca.key 2048
        openssl req -x509 -new -nodes -key ${CONFIG_DIR}/ca.key -sha256 -days 365 -out ${CONFIG_DIR}/ca.pem -subj "/CN=${POJDE_NG_DOMAIN}"

        touch ${RAN_FILE}
    fi

    # Generate server key
    openssl genrsa -out ${OUT_DIR}/server.key 2048
    openssl req -new -key ${OUT_DIR}/server.key -out ${OUT_DIR}/server.csr -subj "/CN=${POJDE_NG_DOMAIN}"

    # Generate server cert
    openssl x509 -req -in ${OUT_DIR}/server.csr -CA ${CONFIG_DIR}/ca.pem -CAkey ${CONFIG_DIR}/ca.key -CAcreateserial -out ${OUT_DIR}/server.crt -days 365 -sha256 -extfile <(echo "authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
IP.1 = ${POJDE_NG_IP}
DNS.1 = localhost
DNS.2 = localhost.localdomain
DNS.4 = local.local
DNS.4 = ${POJDE_NG_DOMAIN}")

    # Append `ssl` to the listen directives of the nginx config
    sed -i 's/\(listen [0-9][0-9][0-9][0-9]\);/\1 ssl;/g' /etc/nginx/conf.d/pojde-ng.conf

    # Add cert and key of the nginx config
    sed -i "s/# %POJDE_NG_CERTIFICATES%/ssl_certificate server.crt;\n    ssl_certificate_key server.key;\n    server_name ${POJDE_NG_DOMAIN};\n    error_page 497 https:\/\/\$host:\$server_port\$request_uri;/g" /etc/nginx/conf.d/pojde-ng.conf

    # Enable & restart the services
    if [ "${POJDE_NG_OPENRC}" = 'true' ]; then
        rc-service nginx restart
        rc-update add nginx default
    else
        systemctl enable nginx
        systemctl restart nginx
    fi
}

# Refresh script
function refresh() {
    :
}
