#!/bin/bash

CALMEQ_DIR=/opt/calmeq-mypi
# this runs on boot (or after fresh download) to ensure the raspberry is properly configured

# ensure bin directory is executable
echo ""
echo "--- make bin directory executable ---"
chmod a+x $CALMEQ_DIR/bin/*

#start gpsd
echo ""
echo "--- update and start gpsd ---"
sudo apt-get install -y gpsd gpsd-clients
gpsd /dev/ttyUSB0

# setup crontab
echo ""
echo "--- setup crontab for pi ---"
crontab -u pi $CALMEQ_DIR/pi.crontab

# make sure we can ssh from middle machine
echo ""
echo "--- setup ssh tunnel ---"
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


# setup the webserver
echo ""
echo "--- update and setup webserver ---"
sudo apt-get install -y apache2
cp $CALMEQ_DIR/apache2/default /etc/apache2/sites-available/default
sudo apachectl -k start  # it should be up by default, but just to make sure


# done!
echo ""
echo "--- Setup Complete ---"

