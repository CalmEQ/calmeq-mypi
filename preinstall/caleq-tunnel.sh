#!/bin/bash

# ------------------------------
# autossh reverse tunnel on boot
# ------------------------------
# See autossh and google for reverse ssh tunnels to see how this works

# When this script runs it will allow you to ssh into this machine even if it is behind a firewall or has a NAT'd IP address.
# From any ssh capable machine you just type ssh -p $MYPORT localusername@middleman

MYID=$(cat /etc/calmeq-device-id)
MYPORT=$((3000 + $MYID))
LOCALUSER="pi"

MIDDLEUSER=ubuntu
MIDDLEIP=52.25.118.79

# middle man private(?) id file for logging into aws ec2 host
IDFILE=/home/pi/.ssh/calmeq-tunnel.pem

# Connection monitoring port, don't need to know this one
AUTOSSH_PORT=27554

# Ensures that autossh keeps trying to connect
AUTOSSH_GATETIME=0

export AUTOSSH_PORT AUTOSSH_GATETIME


echo su -c "autossh -f -N -R $MYPORT:localhost:22 -i $IDFILE ${MIDDLEUSER}@$MIDDLEIP" $LOCALUSER &
