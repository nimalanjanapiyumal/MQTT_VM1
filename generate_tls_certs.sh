#!/usr/bin/env bash
set -euo pipefail

CERT_DIR="/etc/mosquitto/certs"
BROKER_IP="192.168.1.10"
BROKER_DNS="mws-mqtt-broker"

mkdir -p "$CERT_DIR"
cd "$CERT_DIR"

# Create a local lab CA.
openssl genrsa -out ca.key 4096
openssl req -x509 -new -nodes -key ca.key -sha256 -days 3650 \
  -subj "/C=AU/ST=WA/L=Perth/O=Metronia Water Services Lab/OU=CSI2450/CN=MWS-Lab-CA" \
  -out ca.crt

# Create broker key and CSR.
openssl genrsa -out broker.key 2048
openssl req -new -key broker.key \
  -subj "/C=AU/ST=WA/L=Perth/O=Metronia Water Services Lab/OU=MQTT/CN=${BROKER_DNS}" \
  -out broker.csr

cat > broker_ext.cnf <<EOF
subjectAltName = @alt_names
extendedKeyUsage = serverAuth

[alt_names]
DNS.1 = ${BROKER_DNS}
IP.1 = ${BROKER_IP}
EOF

# Sign broker certificate with the local lab CA.
openssl x509 -req -in broker.csr -CA ca.crt -CAkey ca.key -CAcreateserial \
  -out broker.crt -days 825 -sha256 -extfile broker_ext.cnf

chown -R mosquitto:mosquitto "$CERT_DIR"
chmod 755 "$CERT_DIR"
chmod 644 ca.crt broker.crt
chmod 600 ca.key broker.key

# Make CA easy to copy to client VMs.
if [[ -n "${SUDO_USER:-}" && -d "/home/${SUDO_USER}" ]]; then
  cp ca.crt "/home/${SUDO_USER}/mws-ca.crt"
  chown "${SUDO_USER}:${SUDO_USER}" "/home/${SUDO_USER}/mws-ca.crt"
  chmod 644 "/home/${SUDO_USER}/mws-ca.crt"
fi

echo "TLS certificates created in ${CERT_DIR}. Client CA copy: /home/${SUDO_USER:-root}/mws-ca.crt"
