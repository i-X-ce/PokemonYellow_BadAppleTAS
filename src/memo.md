## チャートメモ

### ポケモン入れ替え v.0

1. 1 -> 9 どうぐ欄拡張
1. 21 -> 26 ライバル名をスクリプトに
1. 25 -> 15 分離したライバル名(て)をつなげる
1. 11 -> 10 ライバル名をどうぐ上部に引き上げる
1. どうぐの入れ替え・個数調整
   1. 13,モンスターボール\*118(76h)
   1. 14 -> 18
   1. 19,わざマシン 45\*34(22h)
   1. 19 -> 15
   1. 14,ピーピーエイド\*240(F0h)
1. 10 -> 11 ライバル名をスクリプトに戻す

### ポケモン入れ替え v.1

フリーズのもととなる 00h のどうぐの表示や調整をなくした  
~~ちょっと遅い~~

1. 1 -> 9 どうぐ欄拡張
1. 14 -> 21 FFh の塊をせっていのメモリに
1. せってい(F5h) FFh の塊を F5h に
1. 21 -> 14 FFh の塊を上に引き上げる
1. どうぐの調整
   1. 4,わざマシン 55 全て捨てる
   1. 3,わざマシン 55 全て捨てる
   1. 2,わざマシン 55\*118(76h)
   1. 3,わざマシン 45\*240(F0h)
   1. 4,わざマシン 45\*34(22h)
1. 21 -> 26 ライバル名をスクリプトに
1. 25 -> 15 分離したライバル名(て)をつなげる
1. 14 -> 24 調整したコードをぶち込む

### 入力するコード

```
D2E1~
76 00 F0 F5 22 3C 28 06 00 00 00 C3 E1 D2

D2EF~
3E 01 EA 00 D0 F3 21 B2 D9 3E 10 E0 00 F0 00 47 CB 30 F0 00 A8 22 47 FE FD 20 0E FA 1E D3 3C EA 1E D3 FE 03 D2 B2 D9 18 E4 AF EA 1E D3 18 DE 00 FF
```

## レジスタメモ

### LCD 関連

| アドレス | bit | 役割                                                           | r/w |
| -------- | --- | -------------------------------------------------------------- | --- |
| FF40     | 5   | WIN 表示有効                                                   | r/w |
|          | 4   | タイルデータ変更(0=8800~, 1=8000~)                             | r/w |
| FF41     | 1-0 | モードフラグ(0=H-Blank,1=V-Blank,2=OAM-RAM,3=ドライバ(w 不可)) | r/w |
| FF42     |     | スクロール Y 座標                                              | r/w |
| FF44     |     | LY                                                             | r/w |
| FF47     |     | パレット                                                       | r/w |
| FF4A     |     | WINY 座標                                                      | r/w |

### マスターボリューム

| アドレス | bit | 役割         | r/w |
| -------- | --- | ------------ | --- |
| FF24     | 7   | VIN 左       | r/w |
|          | 6-4 | 左ボリューム | r/w |
|          | 3   | VIN 右       | r/w |
|          | 2-0 | 右ボリューム | r/w |

ボリューム 0 は 1 として扱われる

### TIMA

| アドレス | bit | 役割                                                                                  | r/w |
| -------- | --- | ------------------------------------------------------------------------------------- | --- |
| FF05     |     | タイマーカウンター 指定されて周波数でインクリメントされる。0 に戻ると FF0Fbit2 が立つ | r/w |
| FF06     |     | タイマ・モジュロ TIMA が 0 に戻った時にこの値にリセットされる                         | r/w |
| FF07     | 2   | タイマーの on/off(0=停止, 1=有効)                                                     | r/w |
|          | 1-0 | クロックセレクト (00:4096Hz, 01:262144Hz, 10:65536Hz, 11:16384Hz)                     | r/w |

### ch3

| アドレス | bit | 役割                                                          | r/w |
| -------- | --- | ------------------------------------------------------------- | --- |
| FF1A     | 7   | サウンドの on/off (0=停止, 1=再生)                            | r/w |
| FF1B     | 7-0 | サウンド長 (256 - x) \* (1 / 256)秒                           | ?   |
| FF1C     | 6-5 | ボリューム 0:0%, 1:100%, 2:50%, 3:25%                         | r/w |
| FF1D     | 7-0 | 周波数下位データ 65536 / (2048 - x)Hz                         | w   |
| FF1E     | 2-0 | 周波数上位データ                                              | w   |
|          | 7   | 初期化 (1=サウンドのスタート)                                 | w   |
|          | 6   | カウンタ/継続の切り替え (1=長さが経過した後出力が停止される)  | r/w |
| FF30~    |     | 波形パターン 32 個の 4bit サンプル 上位 4bit が先に再生される | r/w |

波形を変えるときは FF1A を停止にしておかなければいけない

## TAStudio メモ

### フレームを全選択する方法

1. 最後のフレームにカーソルを合わせておく
1. 最初のフレームに移動し、左クリックでドラッグする
1. 右クリックを押しながらホイールを回す

## lsnes メモ

### ゲームの起動

適当な ROM をドラッグするだけ。  
パスに日本語があると起動しない。

### lua の実行

Tools の「Run lua script」を選ぶ
実行前に「Reset Lua VM」をしないと前に実行したスクリプトが残り続けるので注意

### movie の再起動

Movie の「Rewind to start」を選ぶ
Movie の「Readonly mode」にチェックが入っていると入力がされないので注意

### コントローラ入力の確認

Tools の「Edit movie」を選ぶ

### 行っている一連の動作

1. Gameboy の「Pause/Unpause」を選んで止めておく
1. Movie の「Rewind to start」を選ぶ
1. Movie の「Readonly mode」を解除する
1. Tools の「Reset Lua VM」を選ぶ
1. Tools の「Run Lua script」を選ぶ
1. Gameboy の「Pause/Unpause」を選んで動かす
