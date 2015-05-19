#!/bin/bash

CALMEQ_DIR=/opt/calmeq-mypi
# this runs on boot (or after fresh download) to ensure the raspberry is properly configured

# ensure bin directory is executable
echo "make bin directory executable"
chmod a+x $CALMEQ_DIR/bin/*

# setup crontab
echo "setup crontab for pi"
crontab -u pi $CALMEQ_DIR/pi.crontab

# make sure we have the latest tunnel script
echo "get the latest tunnel script"
diff $CALME_DIR/opt/calmeq-mypi/preinstall/calmeq-tunnel.sh /etc/network/if-up.d
if [[ $? -ne 0 ]]; then 
    /bin/cp $CALME_DIR/opt/calmeq-mypi/preinstall/calmeq-tunnel.sh /etc/network/if-up.d/
fi
/bin/pidof autossh
if [[ $? -ne 0 ]]; then 
    /etc/network/if-up.d/calmeq-tunnel.sh &
fi

# done!
echo "Setup Complete"

