import cv2
import numpy as np
import os
import math

script_dir = os.path.dirname(os.path.abspath(__file__))
os.chdir(script_dir)

# 画像を読み込む
quality = 4 # 画素(1タイルにつき何分割するか)
image = cv2.imread("./img/00.png", cv2.IMREAD_GRAYSCALE)
h = image.shape[0]
w = image.shape[1]
bits = min(h / 9, w / 10)
image = image[math.floor((h - bits * 9) / 2): math.floor((h + bits * 9 ) / 2), 
              math.floor((w - bits * 10) / 2): math.floor((w + bits * 10) / 2)]
image = cv2.resize(image, (20 * quality, 18 * quality))

# 4階調に量子化する
bins = np.linspace(0, 256, num=5)  # 4階調 + 1（256は含めない）
quantized = np.digitize(image, bins) - 1  # 0～3のインデックスに変換
levels = np.array([0, 85, 170, 255], dtype=np.uint8)  # 4つのグレースケールの値
image_4color = levels[quantized]  # 量子化した画像を適用

# 表示のために画像をリサイズ・ピクセルをはっきり表示
image_4color = cv2.resize(image_4color, (800, 720), interpolation=cv2.INTER_NEAREST)

# 結果を保存＆表示
cv2.imwrite("output.jpg", image_4color)
cv2.imshow("4 Colors Grayscale", image_4color)
cv2.waitKey(0)
cv2.destroyAllWindows()