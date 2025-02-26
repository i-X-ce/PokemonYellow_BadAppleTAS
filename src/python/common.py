# 16進数を入力用の文字列に変換 Bボタンは反転 len=桁数
def hex2input(hex, len=2):
    inputDict = { 0: "A", 1: "B", 2: "s", 3: "S" }
    s = ""
    for m in range(len):
        for key, value in inputDict.items():
            if (((hex >> ((len - m - 1) * 4)) & (1 << key)) != 0) ^ (key == 1):
                s += value
            else:
                s += "."
        s += "\n"
    return s

print(hex2input(0x13))