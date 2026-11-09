#!/usr/bin/env bash
# Configure nginx as a round-robin load balancer. Args: backend IPs
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
if ! command -v nginx >/dev/null 2>&1; then
  apt-get update -qq
  apt-get install -y -qq nginx >/dev/null
fi

{
  echo "upstream app_pool {"
  for ip in "$@"; do
    echo "    server ${ip}:5000 max_fails=2 fail_timeout=10s;"
  done
  echo "}"
  cat <<'NGINX'
server {
    listen 80 default_server;
    location = /healthz {
        default_type text/plain;
        return 200 "lb ok\n";
    }
    location / {
        proxy_pass http://app_pool;
        proxy_connect_timeout 2s;
        proxy_next_upstream error timeout http_502;
        add_header X-Upstream $upstream_addr always;
    }
}
NGINX
} > /etc/nginx/conf.d/lab-lb.conf

rm -f /etc/nginx/sites-enabled/default
nginx -t
if pgrep -x nginx >/dev/null; then nginx -s reload; else nginx; fi
echo "lb backends: $*"
