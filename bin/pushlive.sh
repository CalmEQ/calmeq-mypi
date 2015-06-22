#!/bin/bash

#set -e -x
# Script to update the website
if [[ $1 ]]; then
    ONCE=$1
else
    ONCE=0 #some dummy value other than 1
fi

# set environment
. /opt/calmeq-mypi/env.sh

# set variables
PYDIR=/opt/calmeq-mypi/python
MAC=$( cat /sys/class/net/eth0/address )
DELAY=60

if [[ ! $CALMEQ_DEVICE_SERVER ]]; then
    CALMEQ_DEVICE_SERVER="http://calmeq-devices.herokuapp.com"
#    CALMEQ_DEVICE_SERVER="https://calmeq-devices-alpharigel.c9.io"
fi

TRUEVAR=1
ID=$( curl -X POST --data identifier=$MAC $CALMEQ_DEVICE_SERVER/pies )
if [ $ID -eq 0 ]; then
    TRUEVAR=0
fi
SITE=$CALMEQ_DEVICE_SERVER/pies/$ID/readings
    
while [ $TRUEVAR -eq 1 ]; do 
    LAT=$( tail -n 30 ~/gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lat="\([-0-9.]*\)".*:\1:g' )
    LON=$( tail -n 30 ~/gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lon="\([-0-9.]*\)".*:\1:g' )
    NOW=$( date )
    DBLVL=$( python $PYDIR/record.py )

    curl -X POST -d "reading[lat]=$LAT" -d "reading[identifier]=$MAC"  -d "reading[lon]=$LON" -d "reading[dblvl]=$DBLVL" -d "reading[devicetime]=$NOW reading[py_id]=$ID"  $SITE

    if [ $ONCE -eq 1 ]; then
	TRUEVAR=0
    else
	sleep $DELAY
    fi
done

echo "Complete!"
