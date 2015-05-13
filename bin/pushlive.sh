#!/bin/bash

# Script to update the website

# set environment
. /opt/calmeq-mypi/env.sh

# set variables
PYDIR=/opt/calmeq-mypi/python
MAC=$( cat /sys/class/net/eth0/address )
DELAY=60

IDFILE=/etc/calmeq-device-id
if [ -f $IDFILE ]; then
    ID=$( cat $IDFILE )
else
    echo "No ID File found at $IDFILE"
    ID=""
fi

amixer -D hw:1 sset Mic Capture Volume 40
SITE=http://calmeq-devices-alpharigel.c9.io/pies/$ID 

while true; do 
    LAT=$( tail -n 30 gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lat="\([-0-9.]*\)".*:\1:g' )
    LON=$( tail -n 30 gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lon="\([-0-9.]*\)".*:\1:g' )
    NOW=$( date )
    DBLVL=$( arecord -d 1 -D hw:1 -f S16_LE -r 44100 -t raw | python $PYDIR/rawaudio2rms.py )

    curl -X PATCH -d "py[lat]=$LAT" -d "py[identifier]=$MAC"  -d "py[lon]=$LON" \
-d "py[dblvl]=$DBLVL" -d "py[devicetime]=$NOW"  $SITE \
    sleep $DELAY
done


