import cv2
import numpy as np
import os
import math
from common import *

# 圧縮する

script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

# デバッグ用
debug = True

quality = 2 # 画素(1タイルにつき何分割するか)
lenY = 18 # タイルの縦
lenX = 20 # タイルの横
skipFrame = 2 # 何フレームごとに処理するか

tileFile = open("movie2.txt", "w") if debug else open("movie.txt", "w")
cap = cv2.VideoCapture("../movies/badapple.mp4")

# 2フレーム分のデータを保存(0x9800, 0x9c00)
prevFrame = [[[0xff for _ in range(20)] for _ in range(18)] for _ in range(2)]
costCnt = 0
if debug: print("Debug mode")
print(f"{math.floor(cap.get(cv2.CAP_PROP_FRAME_COUNT) // skipFrame):,} frames in total.")
costList = []

while cap.isOpened():
    ret, frame = cap.read()
    if not ret:
        break
    frameCnt = int(cap.get(cv2.CAP_PROP_POS_FRAMES))
    if frameCnt % skipFrame != 0:
        continue
    
    # gray = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
    # levels = 4
    # gray_reduced = np.floor(gray / (256 / levels)) * (256 / levels)

    gcd = math.gcd(lenY, lenX)
    ratioY = lenY / gcd 
    ratioX = lenX / gcd
    h = frame.shape[0]
    w = frame.shape[1]
    bits = min(h / ratioY, w / ratioX)
    frame = frame[math.floor((h - bits * ratioY) / 2): math.floor((h + bits * ratioY ) / 2), 
                math.floor((w - bits * ratioX) / 2): math.floor((w + bits * ratioX) / 2)]
    frame = cv2.resize(frame, (lenX * quality, lenY * quality))

    # 4階調に量子化する
    bins = np.linspace(0, 256, num=5)  # 4階調 + 1（256は含めない）
    quantized = np.digitize(frame, bins) - 1  # 0～3のインデックスに変換
    levels = np.array([0, 85, 170, 255], dtype=np.uint8)  # 4つのグレースケールの値
    image_4color = levels[quantized]  # 量子化した画像を適用

    writeAddrInit = 0x9800 if frameCnt % (skipFrame * 2) == 0 else 0x9c00
    prevIndex = 0 if frameCnt % (skipFrame * 2) == 0 else 1
    cost = 0

    if quality == 2:
        tileDict = { 0: 3, 85: 2, 170: 1, 255: 0 }
        for i in range(lenY):
            for j in range(lenX):
                byte = 0
                for k in range(2):
                    for l in range(2):
                        byte = byte * 4 + tileDict[image_4color[i * 2 + 1 - k][j * 2 + l][0]]
                if byte != prevFrame[prevIndex][i][j]:
                    writeAddr = writeAddrInit + i * 32 + j
                    if debug:
                        tileFile.write(f"{writeAddr:04x}{byte:02x}\n")
                    else:
                        tileFile.write(hex2input((writeAddr >> 8) & 0xff)) # 上桁
                        tileFile.write(hex2input(writeAddr & 0xff)) # 下桁
                        tileFile.write(hex2input(byte))
                    prevFrame[prevIndex][i][j] = byte
                    cost += 3

    # 画面切り替えコマンド
    switchCmd = 0x00 if frameCnt % (skipFrame * 2) == 0 else 0x20
    if debug:
        tileFile.write(f"{switchCmd:02x}\n")
    else:
        tileFile.write(hex2input(switchCmd))
    cost += 1
    costList.append(cost)

    # 表示のために画像をリサイズ・ピクセルをはっきり表示
    image_4color = cv2.resize(image_4color, (lenX * 25, lenY * 25), interpolation=cv2.INTER_NEAREST)
    cv2.imshow("4 Colors Grayscale", image_4color)

    # 画像保存
    # cv2.imwrite(f"./img/{frameCnt // skipFrame:05d}.jpg", image_4color)

    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

# 終了コマンド
if debug:
    tileFile.write(f"{0xff:02x}\n")
else:
    tileFile.write(hex2input(0xff))

cap.release()
cv2.destroyAllWindows()
tileFile.close()
print(f"Successful movie output! {costCnt:,} bytes in total.")
costList.sort(reverse=True)
print(f"Max cost: {costList[0:10]}")
