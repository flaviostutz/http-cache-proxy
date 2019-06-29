#!/bin/bash

if [ "$PROXY_PASS_URL" == "" ]; then
    echo "PROXY_PASS_URL environment variable is required"
    exit 1
fi

f="/etc/nginx/conf.d/default.conf"
envsubst < "$f" > "$f"

cat "$f"

echo "Starting nginx on port 80""
nginx -g "daemon off;"
