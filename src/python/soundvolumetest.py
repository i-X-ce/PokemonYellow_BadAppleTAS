from pydub import AudioSegment
import numpy as np
import scipy.signal
import os
import scipy
import scipy.io.wavfile as wav

script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

# 量子化サイズ
quantizeSize = 8
# 音声サイズ
audioSize = 8192
# 新しいサンプリングレート
rate = 9198

audio = AudioSegment.from_file("./music/test.mp3")
audio = audio.set_channels(1).set_frame_rate(44100)

samples = np.array(audio.get_array_of_samples(), dtype=np.float32)

numSamples = int(len(samples) * rate / 44100)
resampledData = scipy.signal.resample(samples, numSamples)

# resampledData *= 16
minData = np.min(resampledData)
maxData = max(abs(minData), abs(np.max(resampledData)))
quantrizedData = np.floor(((resampledData - minData) / (maxData - minData)) * quantizeSize).astype(np.uint8)

wav.write("./music/output.wav", rate, quantrizedData[:audioSize])
print(quantrizedData.shape)

musicFile = open("./music/music.txt", "w")

# for i in range(audioSize // 16):
#     volumes = ""
#     masterVolumes = ""
#     for j in range(1, 16):
#         v, m = divisionVolume(quantrizedData[i * 16 + j])
#         volumes += v
#         masterVolumes += m
#     v, m = divisionVolume(quantrizedData[i * 16])
#     volumes += v
#     masterVolumes += m
#     musicFile.write(volumes + masterVolumes + "\n")



# start = 0
# for i in range(start, start + 8192):
#     musicFile.write(format(min(quantrizedData[i], 16), 'x'))

for i in range(0, audioSize // 32):
    s = ""
    for j in range(1, 32):
        data = format(min(quantrizedData[i * 16 + j], 15), 'x')
        s += data + data
    data = format(min(quantrizedData[i * 16], 15), 'x')
    s += data + data
    musicFile.write(s + "\n")


    

# fps = 60
# samplesPerFrame = 274

# for i in range(0, len(resampledData), newRate // fps):
#     frameSamples = resampledData[i: i + samplesPerFrame]
    
