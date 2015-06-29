import pyaudio
import numpy
import scipy.io.wavfile as wav
from scipy.signal import lfilter
from numpy import pi, polymul
from scipy.signal import bilinear
 
RECORD_SECONDS = 10

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
 
# initialize portaudio
p = pyaudio.PyAudio()
info = p.get_host_api_info_by_index(0)
numdevices = info.get('deviceCount')

#find USB audio device by iterating through each audio device
for i in range (0,numdevices):
    if "USB" in p.get_device_info_by_host_api_device_index(0,i).get('name'):
        device_index = i

devinfo = p.get_device_info_by_index(device_index)

RATE=int(devinfo["defaultSampleRate"])
CHUNKSIZE = RATE / 10
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
b, a = A_weighting(RATE)
y = lfilter(b, a, numpydata)
db = 10*numpy.log10(rms_flat(y)) + 47
#print('A-weighted: {:+.2f} dB'.format(db))

#rms = numpy.sqrt(numpy.mean(numpydata**2))
#dbfm = 20 * numpy.log10(rms)
#db = dbfm + 17
print(db)

# close stream
stream.stop_stream()
stream.close()
p.terminate()