#!/bin/bash

if [ "$PROXY_PASS_URL" == "" ]; then
    echo "PROXY_PASS_URL environment variable is required"
    exit 1
fi


f="/etc/nginx/conf.d/default.conf"
if [ ! -f  /tmp/default.conf ]; then
    echo "Preparing configuration file..."
    envsubst < "$f" > /tmp/default.conf
    cp /tmp/default.conf $f
    sed -i 's/#request_method/\$request_method/g' $f
    sed -i 's/#scheme#proxy_host#uri#is_args#args/\$scheme\$proxy_host\$uri\$is_args\$args/g' $f
fi

echo $f
cat "$f"

echo "Starting nginx on port 80"
nginx -g "daemon off;"
