#!/bin/bash
# /etc/init.d/calmeq-init.sh

### BEGIN INIT INFO
# Provides:          calmeq-init.sh
# Required-Start:    $remote_fs $syslog
# Required-Stop:     $remote_fs $syslog
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: Simple script to start a program at boot
# Description:       A simple script from www.stuffaboutcode.com which will start / stop a program a boot / shutdown.
### END INIT INFO

# this script needs to be preinstalled on noobs

# keep this short, and instead put much of the logic in the mypi github:

# pull mypi repo
MYDIR=/opt/calmeq-mypi

if [ ! -d $MYDIR ]; then
    git clone https://github.com/CalmEQ/calmeq-mypi.git $MYDIR
else
    PREVDIR=$( pwd )
    cd $MYDIR
    git pull
    cd $PREVDIR
fi

sudo apt-get install -y gpsd gpsd-clients

# run first time
. $MYDIR/mypi-init.sh
