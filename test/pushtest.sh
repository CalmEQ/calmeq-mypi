#!/bin/bash

# point to the QA server
#CALMEQ_DEVICE_SERVER="http://calmeq-devices-qa.herokuapp.com"
CALMEQ_DEVICE_SERVER="http://calmeq-devices-alpharigel.c9.io"
export CALMEQ_DEVICE_SERVER

NOW=$( date +"%Y%m%d%H%M%S" )

# push some data to it
/opt/calmeq-mypi/bin/pushlive.sh 1

# confirm that the latest data is there
IDFILE=/etc/calmeq-device-id
if [ -f $IDFILE ]; then
    ID=$( cat $IDFILE )
else
    echo "No ID File found at $IDFILE"
    ID=""
fi
SITE=$CALMEQ_DEVICE_SERVER/pies/$ID/readings

LASTDATE=$( curl "$CALMEQ_DEVICE_SERVER/pies/$ID/readings" -o - | grep UTC | tail -n 1 | sed 's:<[^>]*>::g' )
THEN=$( date -d "$LASTDATE" +"%Y%m%d%H%M%S" )
if [ $NOW -le $THEN ]; then
    echo "Successful push"
else
    echo "failed push"
fi

[ $NOW -le $THEN ]