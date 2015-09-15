"""
    Given a site address, log the current internal tempature to the website.
    This is a proof of concept for live updating information from the raspberry 
    to our device site. It uses Python on the device and Rails with AJAX on the 
    website
"""

#from . import record_and_push.py
import requests
import subprocess
import json
import time
import logging
import expanduser
import argparse

SLEEP_TIME = 1

output = subprocess.check_output("cat /sys/class/net/eth0/address", shell=True)
MAC=output.strip("\n")

home = expanduser("~")
LOG_FILENAME = home + '/record_and_push.log'

# Set up a specific logger with our desired output level
my_logger = logging.getLogger('MyLogger')
my_logger.setLevel(logging.DEBUG)

# Add the log message handler to the logger
handler = logging.handlers.RotatingFileHandler(
              LOG_FILENAME, maxBytes=1048576, backupCount=5)

my_logger.addHandler(handler)


CALMEQ_DEVICE_SERVER_PROD="http://calmeq-devices.herokuapp.com"
CALMEQ_DEVICE_SERVER_QA="http://calmeq-devices-qa.herokuapp.com"
CALMEQ_DEVICE_SERVER_DEV="https://calmeq-devices-alpharigel.c9.io"

def register_device( siteaddress, once=False ):
    """ 
    Get the device number from the server
    """
    while True:
        payload = { 'py': {'identifier': MAC } }
        headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
        site = siteaddress + "/pies"
        r = requests.post( site, data=json.dumps(payload), headers=headers)
        status = r.status_code
        if status == 200:
            break
        else:
            my_logger.debug('registering device returned %d. Retrying after 30 seconds' % status)
            if once:
                break
            else:
                time.sleep(30)

    if callable(r.json):
        return r.json().get('id')
    else:
        return r.json['id']

def push_data(db, id, siteaddress):
    """
    push new data to the website
    """
    SITE = siteaddress + "/pies/" + str(id) + "/tempatures"
    temp = "tail -n 30 ~/gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lat=\"\([-0-9.]*\)\".*:\\1:g'"
    output = subprocess.check_output(temp, shell=True)
    LAT=output.strip("\n")
    temp="tail -n 30 ~/gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lon=\"\([-0-9.]*\)\".*:\\1:g'"
    output = subprocess.check_output(temp, shell=True)
    LON=output.strip("\n")
    output = subprocess.check_output("date", shell=True)
    NOW=output.strip("\n")

    payload = {'reading': {'lat':LAT, 'lon':LON, 'devicetime':NOW, 'dblvl':db} };
    headers = {'Content-Type': 'application/json', 'Accept': 'application/json'}
    r = requests.post( SITE, data=json.dumps(payload), headers=headers)

    if r.status_code != 200:
        my_logger.debug('push data returned error %d' % r.status_code)
    else:
        my_logger.debug('pushing noise level %.4f, response status %d' %(db, r.status_code))
    return r.status_code


def main(  insiteaddress="PROD", once=False ):
    """
    log the tempature to the website. Reuse initially generated tempature 
    multiple times in order to limit bandwith usage.
    """

    # replacement for switch statement. the get() at the end returns a default value if it is not found
    # http://stackoverflow.com/questions/60208/replacements-for-switch-statement-in-python
    siteaddress = {
        'PROD': CALMEQ_DEVICE_SERVER_PROD,
        'QA':   CALMEQ_DEVICE_SERVER_QA,
        'DEV':  CALMEQ_DEVICE_SERVER_DEV,
        }.get( insiteaddress, insiteaddress )

    ID=register_device( siteaddress )
    print "device id on server is", ID
    my_logger.debug('device id on server is %d' % ID)

    loop=1
    ma = []
    count = 0
    while loop:
        db = 0;
        push_data(db, ID, siteaddress)

        # break out if running only once
        if once:
            break
        
        # else sleep if off
        time.sleep(SLEEP_TIME)

    return True



if __name__ == "__main__":
    parser = argparse.ArgumentParser();
    parser.add_argument("-o", "--once", help="run the script once, instead of looping",
                        action="store_true" )
    parser.add_argument("-s", "--site", help="device server to use, such as PROD, QA," 
                        + "or DEV, or an full server address", default="PROD" )
    args = parser.parse_args();

    main( args.site, args.once )
