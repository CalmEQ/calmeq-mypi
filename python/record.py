import pyaudio
import numpy
import scipy.io.wavfile as wav

RECORD_SECONDS = 10

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
rms = numpy.sqrt(numpy.mean(numpydata**2))
dbfm = 20 * numpy.log10(rms)
db = dbfm + 17
print(db)

# close stream
stream.stop_stream()
stream.close()
p.terminate()
