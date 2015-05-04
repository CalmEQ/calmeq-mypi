# Modifications needed for a fresh NOOBS to be ready to go

### How to modify noobs
http://www.i-programmer.info/programming/hardware/7688-real-raspberry-pi-custom-noobs.html?start=1

### our modifications for noobs
1. Place calmeq-init.sh /etc/init.d and ensure its executable
2. create a symlink from /etc/rc2.d/S10calmeq-init to /etc/init.d/calmeq-init.sh
3. add the calmeq device id to /etc/calmeq-device-id *This is device specific*
4. modify the /home/pi/.profile to source the /opt/calmeq-mypi/.profile

```bash
# source calmeq profile 
CALMEQ_PROFILE=/opt/calmeq-mypi/.profile
if [ -f CALMEQ_PROFILE ]; then
    . $CALMEQ_PROFILE
else
    echo "Unable to locate $CALMEQ_PROFILE to source"
fi
```

The calmeq-init.sh script is very simple. it checks out or updates the calmeq-mypi directory in /opt and runs the init script saved there.

