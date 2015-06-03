#!/bin/bash                                                                                                              

#deletewifi.sh ID removes the wifi info for this raspberry pi                                           

ID=$1

sudo /sbin/wpa_cli -i wlan0 remove_network $ID
sudo /sbin/wpa_cli -i wlan0 save_config


