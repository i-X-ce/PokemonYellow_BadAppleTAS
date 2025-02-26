from pydub import AudioSegment
import numpy as np
import scipy.signal
import os
import scipy
import scipy.io.wavfile as wav
from common import *

# μ-law 量子化関数（16レベル）
def mu_law_encoding(audio, mu=15):
    audio = np.sign(audio) * np.log1p(mu * np.abs(audio)) / np.log1p(mu)
    return np.round((audio + 1) * mu / 2).astype(np.uint8)  # 0〜15にマッピング

# ディザリング関数（ホワイトノイズを加える）
def add_dithering(audio, noise_level=0.01):
    noise = np.random.uniform(-noise_level, noise_level, audio.shape)
    return audio + noise

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

# リサンプリング
numSamples = int(len(samples) * rate / 44100)
resampledData = scipy.signal.resample(samples, numSamples)

# 正規化（-1.0〜1.0 にスケーリング）
resampledData = resampledData / np.max(np.abs(resampledData))

# ディザリングを適用
resampledData = add_dithering(resampledData)

# μ-law 量子化を適用
quantrizedData = mu_law_encoding(resampledData)
# 音声の書き込み
wav.write("./music/output.wav", rate, quantrizedData)

# テキストファイルへの書き込み
musicFile = open("./music/sound.txt", "w")
# for i in range(0, quantrizedData.shape[0] // 32):
#     s = ""
#     for j in range(1, 32):
#         s += format(quantrizedData[i * 16 + j], 'x')
#     s += format(quantrizedData[i * 16], 'x')
#     musicFile.write(s + "\n")

for i in range(0, quantrizedData.shape[0] // 32):
    musicFile.write(hex2input(quantrizedData[i * 32 + 31], 1))
    for j in range(31):
        musicFile.write(hex2input(quantrizedData[i * 32 + j], 1))

musicFile.close()
print(f"Successful music output! {quantrizedData.shape[0] // 2} bytes in total.")
