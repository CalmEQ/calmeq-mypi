#!/usr/bin/env python 

import os
import time
import pyaudio
import numpy
import scipy.io.wavfile as wav
from scipy.signal import lfilter
from numpy import pi, polymul
from scipy.signal import bilinear
from httplib2 import Http
from urllib import urlencode
import urlparse
import subprocess
import requests
import argparse
import json
import pytest
 
RECORD_SECONDS = 10
CALMEQ_DEVICE_SERVER_PROD="http://calmeq-devices.herokuapp.com"
CALMEQ_DEVICE_SERVER_QA="http://calmeq-devices-qa.herokuapp.com"
CALMEQ_DEVICE_SERVER_DEV="https://calmeq-devices-alpharigel.c9.io"

output = subprocess.check_output("cat /sys/class/net/eth0/address", shell=True)
MAC=output.strip("\n")

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
            print "registering device returned ", status, ". Retrying after 30 seconds"
            if once:
                break
            else:
                time.sleep(30)
                
    if callable(r.json):
        return r.json().get('id')
    else:
        return r.json['id']

def A_weighting(fs):
    """Design of an A-weighting filter.

    b, a = A_weighting(fs) designs a digital A-weighting filter for
    sampling frequency `fs`. Usage: y = scipy.signal.lfilter(b, a, x).
    Warning: `fs` should normally be higher than 20 kHz. For example,
    fs = 48000 yields a class 1-compliant filter.

    References:
       [1] IEC/CD 1672: Electroacoustics-Sound Level Meters, Nov. 1996.

    """
    # Definition of analog A-weighting filter according to IEC/CD 1672.
    f1 = 20.598997
    f2 = 107.65265
    f3 = 737.86223
    f4 = 12194.217
    A1000 = 1.9997
 
    NUMs = [(2*pi * f4)**2 * (10**(A1000/20)), 0, 0, 0, 0]
    DENs = polymul([1, 4*pi * f4, (2*pi * f4)**2],
                   [1, 4*pi * f1, (2*pi * f1)**2])
    DENs = polymul(polymul(DENs, [1, 2*pi * f3]),
                                 [1, 2*pi * f2])
 
    # Use the bilinear transformation to get the digital filter.
    # (Octave, MATLAB, and PyLab disagree about Fs vs 1/Fs)
    return bilinear(NUMs, DENs, fs)

def rms_flat(a):  # from matplotlib.mlab
    """
    Return the root mean square of all the elements of *a*, flattened out.
    """
    return numpy.sqrt(numpy.mean(numpy.absolute(a)**2))
  
def push_data(db, id, siteaddress):
    """
    push new data to the website
    """
    SITE = siteaddress + "/pies/" + str(id) + "/readings"
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
        print "push_data returned error", r.status_code
    else:
        print "pushing noise level = ", db, "response status = ", r.status_code
    return r.status_code

def main(  insiteaddress="PROD", once=False ):
    """
    setup the audio stream and record it
    """

    # replacement for switch statement. the get() at the end returns a default value if it is not found
    # http://stackoverflow.com/questions/60208/replacements-for-switch-statement-in-python
    siteaddress = {
        'PROD': CALMEQ_DEVICE_SERVER_PROD,
        'QA':   CALMEQ_DEVICE_SERVER_QA,
        'DEV':  CALMEQ_DEVICE_SERVER_DEV,
        }.get( insiteaddress, insiteaddress )

    # initialize portaudio
    p = pyaudio.PyAudio()
    device_index=-1
    while device_index == -1:
        info = p.get_host_api_info_by_index(0)
        numdevices = info.get('deviceCount')
        #find USB audio device by iterating through each audio device
        for i in range (0,numdevices):
            if "USB" in p.get_device_info_by_host_api_device_index(0,i).get('name'):
                device_index = i
                break
        if device_index == -1:
            print "Couldnt find USB microphone. Retrying after 30 seconds"
            time.sleep(30)

    devinfo = p.get_device_info_by_index(device_index)

    RATE=int(devinfo["defaultSampleRate"])
    CHUNKSIZE = RATE / 10
    b, a = A_weighting(RATE)

    ID=register_device( siteaddress )
    print "device id on server is", ID

    loop=1
    while loop:
        stream = p.open (rate=RATE,
                         input_device_index=device_index,
                         channels=devinfo['maxInputChannels'],
                         format=pyaudio.paInt16,
                         input=True,
                         frames_per_buffer=CHUNKSIZE)
        frames = [] # A python-list of chunks(numpy.ndarray)
        for _ in range(0, int((RATE / CHUNKSIZE) * RECORD_SECONDS)):
            data = stream.read(CHUNKSIZE)
            frames.append(numpy.fromstring(data, dtype=numpy.int16))

        #Convert the list of numpy-arrays into a 1D array (column-wise)
        numpydata = numpy.hstack(frames)
        #print('Original:   {:+.2f} dB'.format(10*numpy.log10(rms_flat(numpydata)) + 47))
        y = lfilter(b, a, numpydata)
        db = 10*numpy.log10(rms_flat(y)) + 47
        push_data(db, ID, siteaddress)

        # close stream
        stream.stop_stream()
        stream.close()

        # break out if running only once
        if once:
            break
        
        # else sleep if off
        time.sleep(60 - RECORD_SECONDS)

    p.terminate()
    return True

def test_register_device():
    siteaddress=CALMEQ_DEVICE_SERVER_QA
    id = register_device( siteaddress, True )
    assert id >= 0

def test_A_weighting():
    #TODO: @cprohan add a unit test here
    assert True

def test_push_data():
    db = 42.42
    id = 11
    siteaddress = CALMEQ_DEVICE_SERVER_QA
    statuscode = push_data(db, id, siteaddress)
    assert statuscode == 200

@pytest.mark.skipif(os.environ.get('CIRCLECI') == 'true', reason="requires audio card")
def test_main():
    isgood = main( "QA", True )
    assert isgood


if __name__ == "__main__":
    parser = argparse.ArgumentParser();
    parser.add_argument("-o", "--once", help="run the script once, instead of looping",
                        action="store_true" )
    parser.add_argument("-s", "--site", help="device server to use, such as PROD, QA," 
                        + "or DEV, or an full server address", default="PROD" )
    args = parser.parse_args();

    main( args.site, args.once )
