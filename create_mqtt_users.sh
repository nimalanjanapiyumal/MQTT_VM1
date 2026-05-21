#!/usr/bin/env bash
set -euo pipefail

PASSWD_FILE="/etc/mosquitto/passwd"
rm -f "$PASSWD_FILE"

mosquitto_passwd -b -c "$PASSWD_FILE" sensor01 'LabSensor01!ChangeMe'
mosquitto_passwd -b "$PASSWD_FILE" operator01 'LabOperator01!ChangeMe'
mosquitto_passwd -b "$PASSWD_FILE" ids01 'LabIDS01!ChangeMe'
mosquitto_passwd -b "$PASSWD_FILE" attacker01 'LabAttacker01!ChangeMe'

chown mosquitto:mosquitto "$PASSWD_FILE"
chmod 640 "$PASSWD_FILE"

echo "MQTT lab users created in ${PASSWD_FILE}."
