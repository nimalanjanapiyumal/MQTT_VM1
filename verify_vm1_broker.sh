#!/usr/bin/env bash
set -euo pipefail

echo "== VM1 IP address =="
ip -4 addr show

echo "== Mosquitto service =="
systemctl --no-pager status mosquitto || true

echo "== Listener check =="
ss -lntp | grep ':8883' || { echo "TCP/8883 not listening"; exit 1; }

echo "== ACL file =="
cat /etc/mosquitto/aclfile

echo "== Recent Mosquitto logs =="
tail -n 40 /var/log/mosquitto/mosquitto.log || true
