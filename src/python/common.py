# 16進数を入力用の文字列に変換 Bボタンは反転 len=桁数
def hex2input(hex, len):
    inputDict = { 0: "A", 1: "B", 2: "s", 3: "S" }
    for m in range(len):
        s = ""
        for key, value in inputDict.items():
            if (not (hex >> (m * 4)) & (1 << key)) ^ (key == 1):
                s += value
            else:
                s += "."
        s += "\n"
    return s
