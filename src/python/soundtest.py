from pydub import AudioSegment
import numpy as np
import scipy.signal
import os
import scipy
import scipy.io.wavfile as wav

script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

audio = AudioSegment.from_file("./music/test.mp3")
audio = audio.set_channels(1).set_frame_rate(44100)

samples = np.array(audio.get_array_of_samples(), dtype=np.float32)

newRate = 9198
numSamples = int(len(samples) * newRate / 44100)
resampledData = scipy.signal.resample(samples, numSamples)

# resampledData *= 16
minData = np.min(resampledData)
maxData = max(abs(minData), abs(np.max(resampledData)))
quantrizedData = np.floor(((resampledData + abs(minData)) / (maxData + abs(minData))) * 16).astype(np.uint8)

wav.write("./music/output.wav", newRate, quantrizedData[:8092])
print(quantrizedData.shape)

musicFile = open("./music/music.txt", "w")
start = 0
for i in range(start, start + 8192):
    musicFile.write(format(min(quantrizedData[i], 16), 'x'))

# fps = 60
# samplesPerFrame = 274

# for i in range(0, len(resampledData), newRate // fps):
#     frameSamples = resampledData[i: i + samplesPerFrame]
    