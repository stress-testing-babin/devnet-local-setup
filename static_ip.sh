# !/bin/sh

nmcli con mod "Kabelgebundene Verbindung 1" \
  ipv4.addresses "$1/32" \
  ipv4.method "auto"

nmcli con down "Kabelgebundene Verbindung 1"
nmcli con up "Kabelgebundene Verbindung 1"
