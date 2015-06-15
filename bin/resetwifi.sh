#!/bin/bash

#resetwifi.sh interface toggles the wifi up and down  

INTERFACE=$1

sudo /sbin/ifdown  $INTERFACE
sudo /sbin/ifup   $INTERFACE


