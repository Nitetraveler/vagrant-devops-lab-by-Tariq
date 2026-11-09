#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

echo "===== ROLLING UPGRADE: APP1 ====="

ANSIBLE_LIMIT=app1 vagrant provision app1 --provision-with app

echo "Waiting for app1 version 3.0..."

curl -fs --retry 30 --retry-delay 2 --retry-all-errors \
  http://192.168.60.11:5000/ |
  grep -q '"version": "3.0"'

echo "PASS: app1 upgraded to 3.0"

echo
echo "===== ROLLING UPGRADE: APP2 ====="

ANSIBLE_LIMIT=app2 vagrant provision app2 --provision-with app

echo "Waiting for app2 version 3.0..."

curl -fs --retry 30 --retry-delay 2 --retry-all-errors \
  http://192.168.60.12:5000/ |
  grep -q '"version": "3.0"'

echo "PASS: app2 upgraded to 3.0"

echo
echo "===== ROLLING UPGRADE COMPLETE ====="
