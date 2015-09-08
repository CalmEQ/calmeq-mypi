
## todo list

1. Simplify the wifi setup
2. Store 36 hours worth of audio
3. Asyncrenous push of processed data


lets try spinning up a webserver, and putting a php form up to list and then
add wifi info to server. The web server can also list current recordings, 
and other status updates

alternatively we power everything off the devices page, but i think that would
be a bit awkward, and not leave open the backdoors that we want to configure 
the devices



# setting the apache2 root locaiton
change /var/www to the desired location in:
/etc/apache2/sites-available/default

# change www-data to include wpa configurations
https://luiseth.wordpress.com/2012/04/15/in-a-nutshell-add-permissions-with-configuration-files-in-etcsudoers-d/
http://serverfault.com/questions/157272/allow-apache-to-run-a-command-as-a-different-user
http://ubuntuforums.org/showthread.php?t=1397377
1. add www-data to the /etc/sudoers.d files
2. confirm that it worked with sudo sudo -u www-data sudo -l to see that he can do stuff now
3. looks like my configuration was bad, and i still need to execute as sudo in the script



## setting up a SSH tunnel for the raspberry
http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/AccessingInstancesLinux.html
http://www.tunnelsup.com/raspberry-pi-phoning-home-using-a-reverse-remote-ssh-tunnel
https://raymii.org/s/tutorials/Autossh_persistent_tunnels.html
http://www.vdomck.org/2009/11/ssh-all-time.html
1. Create a micro EC2 instance (using ubuntu for consistnency with Pi)
2. Download the pem file for the instance, save in the master pem list
3. Create a elastic ip and assign to instance
4. The pem file non-readable using chmod 400
4. ssh into the insance using
ssh -i .ssh/calmeq-tunnel.pem ubuntu@52.25.118.79
5. set security group to allow port range 2200-2300 (not necessary, and didnt really work)
6. copy the calmeq pem file to the raspberry to allow the lookback
7. start the autossh using 
autossh -M 10984 -N -R 3222:localhost:22 -i .ssh/calmeq-tunnel.pem ubuntu@52.25.118.79 &
8. on the middle machine, generate a ssh key to log into pi without password using
ssh-keygen
9. copy it to the pi using  (leveraging the tunnel we created)
ssh-copy-id -i ~/.ssh/id_rsa.pub -p 3222 pi@localhost
10. connect directly to the pi using
ssh -t -i .ssh/calmeq-tunnel.pem ubuntu@52.25.118.79 "ssh -p 3222 pi@localhost"
11. add the autossh to the init script, 

<sudo apt-get install autossh>

and its not working... not sure why
looks like we didn't have the identify file in the .ssh, need a secure way to get that 
file accross, and would like to not just post it on the interwebs to be seen
instead it should be attached to the image for each raspberry pi

ss -a | grep 300

ssh -t -i ~/.ssh/calmeq-tunnel.pem ubuntu@52.25.118.79 "ssh -p 3001 pi@localhost"


todo: add logging from the autossh script via 
https://akntechblog.wordpress.com/2010/09/11/autossh-for-persistent-reverse-ssh-tunnels/

last notes
https://raymii.org/s/tutorials/Autossh_persistent_tunnels.html


## setting up the webserver on the raspberry pi

https://wiki.archlinux.org/index.php/WPA_supplicant#Connecting_with_wpa_cli

http://superuser.com/questions/341102/how-to-connect-to-a-wifi-from-command-line-under-ubuntu-without-conf-file
http://superuser.com/questions/181517/how-to-execute-a-command-whenever-a-file-changes


gem install sinatra
./ngrok http 4567

setup github webhook using
https://developer.github.com/webhooks/configuring/

setup php authentication later
http://php.net/manual/en/features.http-auth.php

the best faq
https://developer.github.com/guides/building-a-ci-server/



# setting up the second wifi network:
http://www.maketecheasier.com/set-up-raspberry-pi-as-wireless-access-point/


http://www.instructables.com/id/How-to-make-a-WiFi-Access-Point-out-of-a-Raspberry/step2/null/
http://elinux.org/RPI-Wireless-Hotspot
https://www.raspberrypi.org/forums/viewtopic.php?f=36&t=19120

looks like we needed the adafruit comiled version of hostap, which works fine.
however the wlan0 is booting up first, and then dropping the dhcp connection when wlan1 starts
potentially i can redo everything flipping wlan0 and wlan1, but that seems unlikely to help
though that is the method used by other commentators

the two method:
https://www.raspberrypi.org/forums/viewtopic.php?f=28&t=89756
https://www.raspberrypi.org/forums/viewtopic.php?f=63&t=85721



## saved stuff from emulator attempt:
#!/bin/bash

# do stuff here

# get qemu
sudo apt-get install qemu

# get the kernel
wget http://xecdesign.com/downloads/linux-qemu/kernel-qemu

# get the image
wget http://downloads.raspberrypi.org/raspbian_latest

mv raspbian_latest rasbian-wheezy.zip
unzip rasbian-wheezy.zip 

# first boot
qemu-system-arm -kernel kernel-qemu -cpu arm1176 -m 256 -M versatilepb \
 -no-reboot -serial stdio -append "root=/dev/sda2 panic=1 rootfstype=ext4 rw init=/bin/bash" \
 -hda 2015-05-05-raspbian-wheezy.img -nographic -curses



# wpa_cli not working, because 
  Could not connect to wpa_supplicant - re-trying
  Failed to connect to wpa_supplicant - wpa_ctrl_open: No such file or directory

http://unix.stackexchange.com/questions/114066/wifi-error-wpa-supplicant


i suspect that the problem is with the autossh command, which is running when 
wlan1 boots up, thus laucning a second autossh command. this then probably 
creates issues with wlan0 and the other booting up autossh



## python setup

I saved this into a initdev.sh script, but can't find it now so repeating the 
basic steps here. 

1) Get pip through `sudo apt-get install python-pip`
2) get virtualenv through `pip install virtualenv`
3) create a virtual environment through `virtualenv ../venv`
4) use that virutal environment through `source ../venv/bin/activate`
5) pull down the dependencies using `pip install -r requirements.txt`
6) test your code by running `py.test`
