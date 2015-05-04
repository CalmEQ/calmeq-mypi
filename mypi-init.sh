#!/bin/bash

CALMEQ_DIR=/opt/calmeq-mypi/bin/*
# this runs on boot (or after fresh download) to ensure the raspberry is properly configured

# ensure bin directory is executable
echo "make bin directory executable"
chmod a+x $CALMEQ_DIR/bin/*

# setup crontab
echo "setup crontab for pi"
crontab -u pi $CALMEQ_DIR/pi.crontab

# done!
echo "Setup Complete"

