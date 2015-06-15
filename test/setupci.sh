#!/bin/bash

# sets up the CI server
ruby /opt/calmeq-mypi/webhook/ci.rb > ci.ruby.out &

# sets up the tunnel. download package ngrok_2.0.19_linux_arm.zip
/home/pi/ngrok http -subdomain=calmeq-ci --log='stdout' 4567 > log.std &

#wait for good things
wait

