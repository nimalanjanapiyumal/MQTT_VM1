# VM1 - MQTT Broker Setup

Role: MQTT Broker / Mosquitto  
Hostname: `mws-mqtt-broker`  
Static IP: `192.168.1.10/24`

## Files in this folder

- `01-netplan-vm1-mws-mqtt-broker.yaml` - static IP netplan template.
- `mosquitto_secure.conf` - TLS-enabled Mosquitto broker configuration.
- `aclfile` - topic-level authorisation file.
- `generate_tls_certs.sh` - creates local CA and broker certificate with SAN for `192.168.1.10`.
- `create_mqtt_users.sh` - creates lab MQTT users and passwords.
- `setup_vm1_mqtt_broker.sh` - installs and configures the broker.
- `verify_vm1_broker.sh` - verification commands.

## Install order

```bash
sudo hostnamectl set-hostname mws-mqtt-broker
sudo cp 01-netplan-vm1-mws-mqtt-broker.yaml /etc/netplan/01-mws-static.yaml
sudo nano /etc/netplan/01-mws-static.yaml     # change ens33 if your interface has a different name
sudo netplan apply
ip -4 addr show

chmod +x *.sh
sudo ./setup_vm1_mqtt_broker.sh
sudo ./verify_vm1_broker.sh
```

The setup script copies the CA certificate to `/home/<user>/mws-ca.crt`. Copy that certificate to VM2, VM3, VM4 and VM5 as `/tmp/mws-ca.crt` before running their setup scripts.
