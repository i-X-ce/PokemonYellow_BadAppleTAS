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
gcd = math.gcd(lenY, lenX)
ratioY = lenY / gcd 
ratioX = lenX / gcd
image = cv2.imread("./img/01.png", cv2.IMREAD_GRAYSCALE)
h = image.shape[0]
w = image.shape[1]
bits = min(h / ratioY, w / ratioX)
image = image[math.floor((h - bits * ratioY) / 2): math.floor((h + bits * ratioY ) / 2), 
              math.floor((w - bits * ratioX) / 2): math.floor((w + bits * ratioX) / 2)]
image = cv2.resize(image, (lenX * quality, lenY * quality))

# 4階調に量子化する
bins = np.linspace(0, 256, num=5)  # 4階調 + 1（256は含めない）
quantized = np.digitize(image, bins) - 1  # 0～3のインデックスに変換
levels = np.array([0, 85, 170, 255], dtype=np.uint8)  # 4つのグレースケールの値
image_4color = levels[quantized]  # 量子化した画像を適用

# 表示のために画像をリサイズ・ピクセルをはっきり表示
image_4color = cv2.resize(image_4color, (lenX * 25, lenY * 25), interpolation=cv2.INTER_NEAREST)

# 結果を保存＆表示
cv2.imwrite("output.jpg", image_4color)
cv2.imshow("4 Colors Grayscale", image_4color)
cv2.waitKey(0)
cv2.destroyAllWindows()