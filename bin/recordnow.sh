#!/bin/bash
DUR=$1
TZ='America/Los_Angeles'; export TZ
T=$( date +%Y%m%dT%H%M%S%Z )
F=/home/pi/mp3/rec.$T.mp3
amixer -D hw:1 sset Mic Capture Volume 40
arecord -d $DUR -D hw:1 -f S16_LE -r 44100 -t raw | lame -m m -r -h - $F
