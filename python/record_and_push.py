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
 
RECORD_SECONDS = 10
#CALMEQ_DEVICE_SERVER="http://calmeq-devices.herokuapp.com"
CALMEQ_DEVICE_SERVER="https://calmeq-devices-alpharigel.c9.io"

output = subprocess.check_output("cat /sys/class/net/eth0/address", shell=True)
MAC=output.strip("\n")

def register_device():
    while True:
        h = Http()
        data = dict(identifier=MAC)
        resp, content = h.request(CALMEQ_DEVICE_SERVER + "/pies", "POST", urlencode(data))
        status = resp.status
        if status == 200:
            break
        else:
            print "registering device returned ", status, ". Retrying after 30 seconds"
            time.sleep(30)
    return content

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
 
def push_data(db, id):
    SITE=CALMEQ_DEVICE_SERVER + "/pies/" + id + "/readings"
    temp = "tail -n 30 ~/gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lat=\"\([-0-9.]*\)\".*:\\1:g'"
    output = subprocess.check_output(temp, shell=True)
    LAT=output.strip("\n")
    temp="tail -n 30 ~/gpstrack.xml  | grep '<trkpt' | tail -n 1 | sed 's:.*lon=\"\([-0-9.]*\)\".*:\\1:g'"
    output = subprocess.check_output(temp, shell=True)
    LON=output.strip("\n")
    output = subprocess.check_output("date", shell=True)
    NOW=output.strip("\n")
    h = Http()
    temp="reading[lat]=" + LAT + "&reading[lon]=" + LON + "&reading[devicetime]=" + NOW + "&reading[dblvl]=" + str(db)
    url_dict = urlparse.parse_qs(temp)
    resp, content = h.request(SITE, "POST", urlencode(url_dict, True))
    if resp.status != 302:
        print "push_data returned error", resp.status
    else:
        print "pushing noise level = ", db, "response status = ", resp.status

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

ID=register_device()
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
    push_data(db, ID)
    time.sleep(60 - RECORD_SECONDS)
    # close stream
    stream.stop_stream()
    stream.close()

p.terminate()

