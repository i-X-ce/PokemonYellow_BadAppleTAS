from pydub import AudioSegment
import numpy as np
import scipy.signal
import os
import scipy
import scipy.io.wavfile as wav

script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

# 量子化サイズ
quantizeSize = 120
# 音声サイズ
audioSize = 8192
# 新しいサンプリングレート
rate = 9198

class Volume: 
    def __init__(self, volume, mastarVolume):
        self.volume = volume
        self.mastarVolume = mastarVolume
    
    def getVolume(self): 
        return self.volume * self.mastarVolume
    
    def volumeStr(self):
        return format(self.volume, 'x')
    
    def __str__(self):
        return f"""Volume: {self.volume}, MastarVolume: {self.mastarVolume}, TotalVolume: {self.getVolume()}"""


volumeMap = {}
for i in range(16):
    for j in range(1, 9):
        if volumeMap.__contains__(i * j):
            continue
        volumeMap[i * j] = Volume(i, j)
        

# 最も近いボリュームを取得
def closestVolume(volume):
    return min(volumeMap.values(), key=lambda x: abs(x.getVolume() - volume))

audio = AudioSegment.from_file("./music/test.mp3")
audio = audio.set_channels(1).set_frame_rate(44100)

samples = np.array(audio.get_array_of_samples(), dtype=np.float32)

numSamples = int(len(samples) * rate / 44100)
resampledData = scipy.signal.resample(samples, numSamples)

# resampledData *= 16
minData = np.min(resampledData)
maxData = max(abs(minData), abs(np.max(resampledData)))
quantrizedData = np.floor(((resampledData - minData) / (maxData - minData)) * quantizeSize).astype(np.uint8)

# 最も近いボリュームに調整
for i in range(len(quantrizedData)):
    quantrizedData[i] = closestVolume(quantrizedData[i]).getVolume()

wav.write("./music/output.wav", rate, quantrizedData[:audioSize])
print(quantrizedData.shape)

musicFile = open("./music/music.txt", "w")

# volumeを分けて16進数に変換
def divisionVolume(volume):
    V = volumeMap[volume]
    if V == None:
        return "0", "0"
    return format(V.volume, 'x'),  format(V.mastarVolume, 'x')


for i in range(audioSize // 32):
    volumes = ""
    masterVolumes = ""
    for j in range(16):
        V1 = volumeMap[quantrizedData[i * 16 + j * 2]]
        V2 = volumeMap[quantrizedData[i * 16 + j * 2 + 1]]
        sum = V1.getVolume() + V2.getVolume()
        m = round(sum / (V1.volume + V2.volume))
        volumes += V1.volumeStr() + V2.volumeStr()
        masterVolumes += format(m - 1, 'x') + format(m - 1, 'x')
    musicFile.write(volumes + masterVolumes + "\n")



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

# for i in range(0, 512):
#     s = ""
#     for j in range(1, 16):
#         s += format(min(quantrizedData[i * 16 + j], 16), 'x')
#     s += format(min(quantrizedData[i * 16], 16), 'x')
#     musicFile.write(s)


    

# fps = 60
# samplesPerFrame = 274

# for i in range(0, len(resampledData), newRate // fps):
#     frameSamples = resampledData[i: i + samplesPerFrame]
    
