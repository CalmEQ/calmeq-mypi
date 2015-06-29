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
PIES_SITE=$CALMEQ_DEVICE_SERVER/pies

# Leave ID unset.  Script will fetch it from server
ID=

    
while true ; do 

    # Fetch device id, if one is not set. POST on "/pies" with identifier (required) and 
    # other attributes in json format.  
    # Curl error handling notes
    # --fail returns numerical error code instead of an HTML document with an error. Need that
    # --silent supresses crap like progress bar

    if [ -z "$ID" ]; then
        resp_json=$(curl --silent --fail -X POST $PIES_SITE \
        -d '{"py": {"identifier":"'$MAC'", "devicetime":"'$NOW'", "notes":"Hello from Pi"}}' \
        -H "Accept: application/json" -H "Content-Type: application/json")

         if [ ! -z "$resp_json" ]; then
            tmp=$(echo $resp_json | jq '.id')
            if [ ! -z "$tmp" ]; then
                ID=$tmp
            fi
        fi
    fi

    LAT=$( tail -n 30 ~/gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lat="\([-0-9.]*\)".*:\1:g' )
    LON=$( tail -n 30 ~/gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lon="\([-0-9.]*\)".*:\1:g' )
    NOW=$( date )
    DBLVL=$( python $PYDIR/record.py )

    # We many not have device id yet. 
    if [ ! -z "$ID" ]; then
        resp_json=$(curl --silent --fail -X POST $PIES_SITE/$ID/readings \
            -d '{"reading": {"lat":"'$LAT'", "identifier":"'$MAC'", "lon":"'$LON'", "dblvl":"'$DBLVL'", "devicetime":"'$NOW'" }}' \
            -H "Accept: application/json" -H "Content-Type: application/json")
    fi

	sleep $DELAY
done

echo "Complete!"
