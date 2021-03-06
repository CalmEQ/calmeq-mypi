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
   rm $ROOTDIR/etc/init.d/calmeq-init.sh 
fi

echo "Copying init"
/bin/cp calmeq-init.sh $ROOTDIR/etc/init.d
/bin/chmod a+x $ROOTDIR/etc/init.d/calmeq-init.sh
#    update-rc.d calmeq-init.sh defaults

#2. create a symlink from /etc/rc2.d/S10calmeq-init to /etc/init.d/calmeq-init.sh
NLINK=S03calmeq-init.sh
NBASE=$ROOTDIR/etc
SOURCE=$ROOTDIR/etc/init.d/calmeq-init.sh
function checkcreate {
    if [ -f $2 ]; then
        echo "Link already exists"
    else
        echo "Linking to run time environment"
        /bin/ln -s $1 $2
    fi
}
checkcreate $SOURCE $NBASE/rc2.d/$NLINK
checkcreate $SOURCE $NBASE/rc3.d/$NLINK
checkcreate $SOURCE $NBASE/rc4.d/$NLINK
checkcreate $SOURCE $NBASE/rc5.d/$NLINK



#3. add the calmeq device id to /etc/calmeq-device-id *This is device specific*
if [[ $DEVICEID ]]; then
    echo "Setting device id"
    echo $DEVICEID > $ROOTDIR/etc/calmeq-device-id
else
    echo "No device id set"
fi

#4. make sure the ssh tunnel will launch
/bin/cp ./calmeq-tunnel.sh $ROOTDIR/etc/network/if-up.d/

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


