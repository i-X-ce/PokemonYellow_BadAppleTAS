from pydub import AudioSegment
import numpy as np
import scipy.signal
import os
import scipy
import scipy.io.wavfile as wav

script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

# 量子化サイズ
quantizeSize = 16
# 新しいサンプリングレート
rate = 9198

# 音声の読み込み
audio = AudioSegment.from_file("../movies/badapple.mp4", format="mp4")
audio = audio.set_channels(1).set_frame_rate(44100)
samples = np.array(audio.get_array_of_samples(), dtype=np.float32)
numSamples = int(len(samples) * rate / 44100)
resampledData = scipy.signal.resample(samples, numSamples)
minData = np.min(resampledData)
maxData = max(abs(minData), abs(np.max(resampledData)))
quantrizedData = np.floor(((resampledData - minData) / (maxData - minData)) * quantizeSize).astype(np.uint8)

# 音声の書き込み
wav.write("./music/output.wav", rate, quantrizedData)
print(quantrizedData.shape)

# テキストファイルへの書き込み
musicFile = open("./music/music.txt", "w")
for i in range(0, quantrizedData.shape[0] // 32):
    s = ""
    for j in range(1, 32):
        s += format(quantrizedData[i * 16 + j], 'x')
    s += format(quantrizedData[i * 16], 'x')
    musicFile.write(s + "\n")
musicFile.close()
