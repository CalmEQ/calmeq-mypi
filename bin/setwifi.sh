#!/bin/bash 

#setwifi.sh SSID PASSCODE KEYMGMT adds the wifi info for this raspberry pi

SSID=$1
PASSCODE=$2
KEYMGMT=$3


NETID=$(sudo /sbin/wpa_cli -i wlan0 add_network)
sudo /sbin/wpa_cli -i wlan0 set_network $NETID ssid "\"$SSID\""
sudo /sbin/wpa_cli -i wlan0 set_network $NETID psk "\"$PASSCODE\""
sudo /sbin/wpa_cli -i wlan0 set_network $NETID key_mgmt $KEYMGMT
sudo /sbin/wpa_cli -i wlan0 enable_network $NETID
sudo /sbin/wpa_cli -i wlan0 save_config
sudo /sbin/ifdown
sudo /sbin/ifup

 