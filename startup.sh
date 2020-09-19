#!/bin/bash

set -e
# set -x

if [ "$PROXY_PASS_URL" == "" ]; then
    echo "PROXY_PASS_URL environment variable is required"
    exit 1
fi

#LOG LEVEL
if [ "$REQUEST_LOG_LEVEL" == "basic" ]; then
    export LOG_CONFIG_FRAG="    access_log /dev/stdout;"
    export LOG_FORMAT_FRAG=""
elif [ "$REQUEST_LOG_LEVEL" == "body" ]; then
    export LOG_CONFIG_FRAG="$(<log-response.conf)"
    export LOG_FORMAT_FRAG="$(<log-format.conf)"
fi

#SSL SUPPORT
if [ "$SSL_DOMAIN" == "" ]; then
    echo "No SSL domain set. Will listen only to plain HTTP connections on port 80"
    export SERVER_FRAG="$(<server-nonssl.conf)"
else
    echo "SSL domain set to $SSL_DOMAIN. Will listen to HTTPS/2 connections on port 443 and redirect requests from port 80 (HSTS will be applied)."
    envsubst < server-ssl.conf > /tmp/server-ssl.conf && cp /tmp/server-ssl.conf server-ssl.conf
    sed -i 's/#server_name#request_uri/\$server_name$request_uri/g' server-ssl.conf
    export SERVER_FRAG="$(<server-ssl.conf)"

    if [ ! -f /ssl-done ]; then
        echo "Preparing SSL certificates..."

        if [ ! -f /etc/ssl/certs/domain.crt ] || [ ! -f /etc/ssl/private/domain.key ]; then
            echo "SSL certificate and private key were not found at /etc/ssl/certs/domain.crt and /etc/ssl/private/domain.key"
            echo "Generating a self signed certificate for $SSL_DOMAIN..."
            openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
                    -keyout /etc/ssl/private/domain.key \
                    -out /etc/ssl/certs/domain.crt \
                    -subj "/C=BR/ST=DF/L=Brasilia/O=Flavio Stutz/OU=IT Department/CN=$SSL_DOMAIN"
        else
            echo "Using provided certificate at /etc/ssl/certs/domain.crt and /etc/ssl/private/domain.key"
        fi

        echo "Generating Diffie-Hellman file for enhanced security..."
        openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048

        touch /ssl-done
    fi
fi

f="/etc/nginx/conf.d/default.conf"
if [ ! -f  /tmp/default.conf ]; then
    echo "Preparing configuration file..."
    envsubst < "$f" > /tmp/default.conf
    cp /tmp/default.conf $f
    sed -i 's/#request_method/\$request_method/g' $f
    sed -i 's/#host/\$host/g' $f
    sed -i 's/#http_upgrade/\$http_upgrade/g' $f
    # sed -i 's/#http_connection/\$http_connection/g' $f
    sed -i 's/#connection_upgrade/\$connection_upgrade/g' $f
    sed -i 's/#proxy_add_x_forwarded_for/\$proxy_add_x_forwarded_for/g' $f
    sed -i 's/#scheme#proxy_host#uri#is_args#args/\$scheme\$proxy_host\$uri\$is_args\$args/g' $f
fi

# echo "" > /etc/nginx/sites-available/default
# cp /test-default.conf $f

echo "Configuration file $f"
cat --number "$f"

echo "Starting nginx on port 80"
nginx -g "daemon off;"

