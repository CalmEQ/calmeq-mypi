# -*- coding: utf-8 -*-
"""
Created on Mon Apr 27 23:13:50 2015

@author: jdermody
"""


#%%
import sys
#import subprocess as sp
import numpy


# hack for stdin
# remove this once finished downloading
raw_audio = sys.stdin.read()
audio_array = numpy.fromstring(raw_audio, dtype="int16")
newarray = audio_array.astype("float") / (2**15)
    
rms = numpy.sqrt(numpy.mean(newarray**2))
    
dbfm = 20 * numpy.log10(rms)
db = dbfm + 85

print(db)
