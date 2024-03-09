#!/usr/bin/env bash

# set -x

p12_cert=$1
passphrase=$(openssl rand -base64 32)

base="$HOME/.cert/nm-easyroam"
mkdir -p "$base"

client_cert="$base/easyroam_client_cert.pem"
client_key="$base/easyroam_client_key.pem"
root_ca="$base/easyroam_root_ca.pem"

# we use -provider legacy, statt -legacy

# create client cert
openssl pkcs12 -in "$p12_cert" -passin "pass:" -provider legacy -nokeys \
  | openssl x509 -out "$client_cert" 

# get id for connection
common_name=$(openssl x509 -noout -subject -in "$client_cert" -provider legacy \
                | sed 's/.*CN = \(.*\), C.*/\1/')

# create encrypted client key
openssl pkcs12 -provider legacy -in "$p12_cert" -passin "pass:" -nodes -nocerts \
  | openssl rsa -aes256 -out "$client_key" -passout "pass:$passphrase" -provider legacy

# create ca cert
openssl pkcs12 -in "$p12_cert" -passin "pass:" -provider legacy -cacerts -nokeys -out "$root_ca"

# make files user readable only
chmod -R 600 "$base/"*

# remove old connection if already defined
if nmcli --terse connection show eduroam; then
  nmcli connection delete eduroam
fi

# add connection
nmcli connection add \
  type wifi con-name "eduroam" ifname wlp3s0 ssid "eduroam" -- \
  wifi-sec.key-mgmt wpa-eap \
  802-1x.eap tls \
  802-1x.identity "$common_name" \
  802-1x.ca-cert "$root_ca" \
  802-1x.client-cert "$client_cert" \
  802-1x.private-key-password "$passphrase" \
  802-1x.private-key "$client_key"
