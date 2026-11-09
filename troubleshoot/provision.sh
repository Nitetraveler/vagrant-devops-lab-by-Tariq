#!/usr/bin/env bash
set -euo pipefail
export DEBIAN_FRONTEND=noninteractive
if ! command -v nginx >/dev/null 2>&1; then
  apt-get update -qq
  apt-get install -y -qq nginx
fi
cp /srv/content/index.html /var/www/html/index.html
if pgrep -x nginx >/dev/null; then nginx -s reload; else nginx; fi
echo "tshoot provisioning complete"
