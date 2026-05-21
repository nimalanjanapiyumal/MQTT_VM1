#!/usr/bin/env bash
set -euo pipefail

if [[ $EUID -ne 0 ]]; then
  echo "Run with sudo: sudo ./setup_vm1_mqtt_broker.sh"
  exit 1
fi

apt update
apt install -y mosquitto mosquitto-clients openssl ufw tcpdump net-tools

mkdir -p /etc/mosquitto/conf.d /etc/mosquitto/certs /var/log/mosquitto
cp mosquitto_secure.conf /etc/mosquitto/conf.d/mws_secure.conf
cp aclfile /etc/mosquitto/aclfile

./generate_tls_certs.sh
./create_mqtt_users.sh

chown mosquitto:mosquitto /etc/mosquitto/aclfile /etc/mosquitto/passwd
chmod 640 /etc/mosquitto/aclfile /etc/mosquitto/passwd
chown -R mosquitto:mosquitto /etc/mosquitto/certs
chmod 600 /etc/mosquitto/certs/broker.key /etc/mosquitto/certs/ca.key

# Allow secure MQTT only from the local assessment subnet.
ufw allow from 192.168.1.0/24 to any port 8883 proto tcp || true

systemctl enable mosquitto
systemctl restart mosquitto
sleep 2
systemctl --no-pager status mosquitto || true
ss -lntp | grep ':8883' || true

echo "VM1 MQTT broker setup complete. Broker address: 192.168.1.10:8883"
echo "Copy /home/${SUDO_USER:-root}/mws-ca.crt to /tmp/mws-ca.crt on VM2, VM3, VM4 and VM5."
