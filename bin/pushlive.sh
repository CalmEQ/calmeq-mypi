#!/bin/bash

# Script to update the website
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
#SITE=http://calmeq-devices-alpharigel.c9.io/pies/$ID/readings
SITE=http://calmeq-devices.herokuapp.com/pies/$ID/readings

while true; do 
    LAT=$( tail -n 30 ~/gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lat="\([-0-9.]*\)".*:\1:g' )
    LON=$( tail -n 30 ~/gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lon="\([-0-9.]*\)".*:\1:g' )
    NOW=$( date )
    DBLVL=$( arecord -d 1 -D hw:1 -f S16_LE -r 44100 -t raw | python $PYDIR/rawaudio2rms.py )

    curl -X POST -d "reading[lat]=$LAT" -d "reading[identifier]=$MAC"  -d "reading[lon]=$LON" \
-d "reading[dblvl]=$DBLVL" -d "reading[devicetime]=$NOW reading[py_id]=$ID"  $SITE
    sleep $DELAY
done


