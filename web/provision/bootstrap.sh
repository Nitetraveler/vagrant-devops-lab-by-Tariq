#!/usr/bin/env bash
# Idempotent web bootstrap. $1 = host label, SITE_OWNER comes from provisioner env.
set -euo pipefail
HOST_LABEL="${1:-unknown}"
export DEBIAN_FRONTEND=noninteractive

if ! command -v nginx >/dev/null 2>&1; then
  apt-get update -qq
  apt-get install -y -qq nginx >/dev/null
  echo "nginx installed"
else
  echo "nginx already installed - skipping package step"
fi

install -m 0644 /tmp/nginx-site.conf /etc/nginx/sites-available/lab-site
ln -sf /etc/nginx/sites-available/lab-site /etc/nginx/sites-enabled/lab-site
rm -f /etc/nginx/sites-enabled/default

mkdir -p /var/www/meta
cat > /var/www/meta/info.txt <<INFO
host=${HOST_LABEL}
owner=${SITE_OWNER:-unset}
box=$(cat /etc/box-release)
provisioned=$(date -u +%Y-%m-%dT%H:%M:%SZ)
INFO

nginx -t
