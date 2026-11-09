#!/usr/bin/env bash
# (Re)start the app. Safe to run on every boot. $1 = node name
set -euo pipefail
NODE="$1"
install -d /opt/app
install -m 0755 /vagrant/app/app.py /opt/app/app.py
pkill -f /opt/app/app.py || true
APP_NODE="$NODE" APP_VERSION="1.0" \
  setsid nohup python3 /opt/app/app.py > /var/log/app.log 2>&1 < /dev/null &
curl -fs --retry 20 --retry-delay 1 --retry-all-errors http://127.0.0.1:5000/
