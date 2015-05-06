#!/bin/bash

if [[ ! $1 ]]; then
    echo "$0 ROOTDIR DEVICEID modifies the NOOBS installation with the basic calmeq information"
    exit 1
fi

ROOTDIR=$1
DEVICEID=$2

if [ $( whoami ) != "root" ]; then
    echo "must run as root"
    exit 1
fi

# our modifications for noobs

#1. Place calmeq-init.sh /etc/init.d and ensure its executable
if [ -f $ROOTDIR/etc/init.d/calmeq-init.sh ]; then
    echo "Init already exists"
else
    echo "Copying init"
    /bin/cp calmeq-init.sh $ROOTDIR/etc/init.d
    /bin/chmod a+x $ROOTDIR/etc/init.d/calmeq-init.sh
fi

#2. create a symlink from /etc/rc2.d/S10calmeq-init to /etc/init.d/calmeq-init.sh
if [ -f $ROOTDIR/etc/rc2.d/S10calmeq-init ]; then
    echo "Link already exists"
else
    echo "Linking to run time environment"
    /bin/ln -s $ROOTDIR/etc/init.d/calmeq-init.sh $ROOTDIR/etc/rc2.d/S10calmeq-init
fi


#3. add the calmeq device id to /etc/calmeq-device-id *This is device specific*
if [[ $DEVICEID ]]; then
    echo "Setting device id"
    echo $DEVICEID > $ROOTDIR/etc/calmeq-device-id
else
    echo "No device id set"
fi

# dont modify profile because we'll source everything we need from crontab
#
# #4. modify the /home/pi/.profile to source the /opt/calmeq-mypi/.profile
# if grep CALMEQ $ROOTDIR/home/pi/.profile > /dev/null; then
#     echo "profile already modified"
# else
#     echo "adding CalmEQ to profile"
#     cat modprof >> $ROOTDIR/home/pi/.profile
# fi


echo "modification complete!"


