#!/bin/bash

# Script to update the website
if [[ $1 ]]; then
    ONCE=$1
else
    ONCE=""
fi

# set environment
. /opt/calmeq-mypi/env.sh

# set variables
PYDIR=/opt/calmeq-mypi/python
MAC=$( cat /sys/class/net/eth0/address )
DELAY=60

#IDFILE=/etc/calmeq-device-id
#if [ -f $IDFILE ]; then
#    ID=$( cat $IDFILE )
#else
#    echo "No ID File found at $IDFILE"
#    ID=""
#fi

amixer -D hw:1 sset Mic Capture Volume 40

if [[ ! $CALMEQ_DEVICE_SERVER ]]; then
    CALMEQ_DEVICE_SERVER="http://calmeq-devices.herokuapp.com"
fi

SITE=$CALMEQ_DEVICE_SERVER/pies/$ID/readings
TRUEVAR=1
ID=$( curl -X POST --data identifier=$MAC $CALMEQ_DEVICE_SERVER/pies )
if [ $ID -eq 0 ]; then
    TRUEVAR=0
fi
    
while [ $TRUEVAR -eq 1 ]; do 
    LAT=$( tail -n 30 ~/gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lat="\([-0-9.]*\)".*:\1:g' )
    LON=$( tail -n 30 ~/gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lon="\([-0-9.]*\)".*:\1:g' )
    NOW=$( date )
    DBLVL=$( arecord -d 1 -D hw:1 -f S16_LE -r 44100 -t raw | python $PYDIR/rawaudio2rms.py )

    curl -X POST -d "reading[lat]=$LAT" -d "reading[identifier]=$MAC"  -d "reading[lon]=$LON" \
-d "reading[dblvl]=$DBLVL" -d "reading[devicetime]=$NOW reading[py_id]=$ID"  $SITE

    if [ $ONCE -eq 1 ]; then
	TRUEVAR=0
    else
	sleep $DELAY
    fi
done

echo ""
echo "Complete!"
echo ""
