# /opt/calmeq-devices/.profile to execute for login shells specific to calmeq

# should be relatively short, as running scripts should maintain their own environment.
# rather just make sure the master scripts can be found, and any global environment variables are set

# add the bin path
BIN=/opt/calmeq-devices/bin
export PATH="$BIN:$PATH"

# more stuff?
CALMEQ_DEVICE_SERVER="http://calmeq-devices-alpharigel.c9.io/pies/"

# done
echo "Finished sourcing calmeq environment"