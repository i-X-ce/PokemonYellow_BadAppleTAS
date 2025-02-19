import cv2
import numpy as np
import os
import math

script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

# 画像を読み込む
quality = 2 # 画素(1タイルにつき何分割するか)
lenY = 18 # タイルの縦
lenX = 20 # タイルの横

tileFile = open("movie.txt", "w")
cap = cv2.VideoCapture("../movies/badapple.mp4")
frameCnt = 0
while cap.isOpened():
    frameCnt += 1
    ret, frame = cap.read()
    if not ret:
        break
    if frameCnt % 2 == 1:
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

    if quality == 2:
        tileDict = { 0: 0, 85: 1, 170: 2, 255: 3 }
        inputDict = { 0: "A", 1: "B", 2: "s", 3: "S" }
        for i in range(0, lenY):
            for j in range(0, lenX):
                byte = 0
                for k in range(0, 2):
                    for l in range(0, 2):
                        byte = byte * 4 + tileDict[image_4color[i * 2 + k][j * 2 + l][0]]
                for m in range(0, 2):
                    writeStr = ""
                    for key, value in inputDict.items():
                        if (not (byte >> (0 if m == 0 else 4)) & (1 << key)) ^ (key == 1):
                            writeStr += value
                        else:
                            writeStr += "."
                    tileFile.write(writeStr + "\n")

    # 表示のために画像をリサイズ・ピクセルをはっきり表示
    image_4color = cv2.resize(image_4color, (lenX * 25, lenY * 25), interpolation=cv2.INTER_NEAREST)
    cv2.imshow("4 Colors Grayscale", image_4color)

    if cv2.waitKey(1) & 0xFF == ord("q"):
        break

cap.release()
cv2.destroyAllWindows()
tileFile.close()

