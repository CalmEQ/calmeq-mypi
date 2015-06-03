#!/bin/bash

#more /etc/wpa_supplicant/wpa_supplicant.conf
IDS=$( sudo /sbin/wpa_cli -i wlan0 list_networks | tail -n +2 | cut -f 1 )
echo "<table class=\"table table-striped\">"
echo "<thead><tr><th>ID</th><th>SSID</th><th>PSK</th><th>KEY_MGMT</th></tr></thead><tbody>"
for ID in $IDS; do 
    SSID=$( sudo /sbin/wpa_cli -i wlan0 get_network "$ID" ssid )
    PSK=$( sudo /sbin/wpa_cli -i wlan0 get_network "$ID" psk )
    KEY_MGMT=$( sudo /sbin/wpa_cli -i wlan0 get_network "$ID" key_mgmt )
    echo "<tr><td>$ID</td><td>$SSID</td><td>$PSK</td><td>$KEY_MGMT</td></tr>"
done
echo "</tbody></table>"
