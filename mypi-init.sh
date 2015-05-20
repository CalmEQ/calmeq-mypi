#!/bin/bash

CALMEQ_DIR=/opt/calmeq-mypi
# this runs on boot (or after fresh download) to ensure the raspberry is properly configured

# ensure bin directory is executable
echo "make bin directory executable"
chmod a+x $CALMEQ_DIR/bin/*

# setup crontab
echo "setup crontab for pi"
crontab -u pi $CALMEQ_DIR/pi.crontab

# make sure we can ssh from middle machine
grep "$(cat $CALMEQ_DIR/tunnel.rsa.pub)" /home/pi/.ssh/authorized_keys > /dev/null
if [[ $? -ne 0 ]]; then
    if [ ! -d /home/pi/.ssh ]; then
        mkdir /home/pi/.ssh
    fi
    cat $CALMEQ_DIR/tunnel.rsa.pub >> /home/pi/.ssh/authorized_keys
fi

# make sure we have the latest tunnel script
echo "get the latest tunnel script"
diff $CALME_DIR/opt/calmeq-mypi/preinstall/calmeq-tunnel.sh /etc/network/if-up.d > /dev/null
if [[ $? -ne 0 ]]; then 
    /bin/cp $CALME_DIR/opt/calmeq-mypi/preinstall/calmeq-tunnel.sh /etc/network/if-up.d/
fi
/bin/pidof autossh
if [[ $? -ne 0 ]]; then 
    /etc/network/if-up.d/calmeq-tunnel.sh &
fi

# copy over the pem file for the middle machine
# do this manually once
# scp calmeq-tunnel.pem.txt pi@mypi.local:~/.ssh/calmeq-tunnel.pem
# ssh pi@mypi.local  "chmod 400 ~/.ssh/calmeq-tunnel.pem"

# done!
echo "Setup Complete"

