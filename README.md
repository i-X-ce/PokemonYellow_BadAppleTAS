# PokemonYellow_BadAppleTAS

## 目的

- エミュレータ: rr2-β23
- 日本語版で任意コード実行の最速実行を目指す
- BadApple!!を再生する

## コメント

この走りは 2017 年に黄版を使って制作された[とんでもない走り][1]と 2024 年にファミコン版のマリオブラザースを使って制作された[とんでもない走り][2]を参考に作られました。両者のあまりに高精度の操作と、美しいグラフィックに感銘を受けて自分でも同じような走りをしてみようと思い立ち、制作に取り組みました。  
以前 BizHawk を使って BadApple を再生する[TAS 動画][4]を作ったことがありましたが、BizHawk では 1 フレームにつき 1 入力しかできないため、解像度とフレームレートに大きな課題がありました。また、この入力速度ではリアルタイムで送ったデータをそのまま画面に出力することでは間に合わないため一度 SRAM に保存してそれをもとに画像を書き換えるという手段を用いて作られています。そのため動画の容量は SRAM の保存容量に依存し、著しく低いフレームレートと解像度で動画を作るほかありませんでした。さらにそのようなデータ容量では音声まで保存することは困難を極めたので実装ができていません。  
参考にした二つの走りを見ても、サブフレーム単位でのボタン入力ができることは必須条件です。今回の走りではエミュレーターを見直し、サブフレーム単位での入力が可能な lsnes を使うことにしました(以前の走りでもこれを使うべきでしたが、自分の知識不足で扱い方がわかりませんでした)。これによって 1 フレームに一回の入力制限から解放され、1 フレームにつき約 260byte ほどのデータを送信することができるようになりました。送信できるデータ量が大幅に増加したことによって課題だったフレームレートと解像度の低さを解決し、音声の出力にも成功することができました。

## 段階ごとのコメント

この走りは MrWint 氏によって[制作されたもの][1]をもとに制作したため、多くの点で使われた手段が似ています。

### 任意コード実行のセットアップ

MrWing 氏のものと同様、3 段階に分けて実行を行います。

#### 第一段階

SRAM グリッチを成功させたのち、以下の通りに手持ちのポケモンを入れ替えて、マップスクリプトによる実行を行います。下の手順では(入れ替えるポケモン番号->入れ替え先のポケモン番号)で順序を表しています。横のテキストはその時に何が起きているのかを書いています。

1. 1 -> 9 どうぐ欄拡張
1. 14 -> 21 FFh の塊をせっていのメモリに
1. せってい(F5h) FFh の塊を F5h に
1. 21 -> 14 FFh の塊を上に引き上げる
1. どうぐの調整
   1. 4 番目わざマシン 55 全て捨てる
   1. 3 番目わざマシン 55 全て捨てる
   1. 2 番目わざマシン 55\*118(76h)
   1. 3 番目わざマシン 45\*240(F0h)
   1. 4 番目わざマシン 45\*34(22h)
1. 21 -> 26 ライバル名をスクリプトに
1. 25 -> 15 分離したライバル名(て)をつなげる
1. 14 -> 24 調整したコードをぶち込む

この手順を終えたのちにメニューを閉じてマップに戻ることで即マップスクリプトが実行され、ライバルの名前に仕込んだ 0xD2E1~コードが実行されます。途中で'\*'のついている`push af`や`jr nc, D2EC`等はどうぐの入れ替えの時に出てくるゴミで、実行上では無視できます。

```
WRA1:D2E1 76               halt
WRA1:D2E2 F5               push af ; *
WRA1:D2E3 F0 F5            ld   a,(ff00+F5)
WRA1:D2E5 22               ldi  (hl),a
WRA1:D2E6 F5               push af ; *
WRA1:D2E7 00               nop
WRA1:D2E8 00               nop
WRA1:D2E9 00               nop
WRA1:D2EA 30 00            jr   nc,D2EC ; *
WRA1:D2EC C3 E1 D2         jp   D2E1
```

このコードを実行することで 0xD2E1~のコードをボタン入力を使って書き換え、最終的には以下のようなコードになります。

```
WRA1:D2E1 76               halt
WRA1:D2E2 00               nop
WRA1:D2E3 F0 F5            ld   a,(ff00+F5)
WRA1:D2E5 22               ldi  (hl),a
WRA1:D2E6 3C               inc  a
WRA1:D2E7 28 06            jr   z,D2EF
WRA1:D2E9 00               nop
WRA1:D2EA 00               nop
WRA1:D2EB 00               nop
WRA1:D2EC C3 E1 D2         jp   D2E1
```

この書き換えによって無限ループになっていた元のコードに終了条件を加えて、実行の終了を表現できるようになりました。このコードを使って第二段階のコードを下のメモリに書き込んでいきます。  
第二段階のコードには`0xFF(rst 38)`が終端に存在し、これを読み取ることで第一段階の読み込みが終了したことを判定します。これが書き込まれた瞬間に 0xD2EF~の第二段階のコードが実行されます。

#### 第二段階

第一段階で作ったコードで以下のコードを第一段階のコードの直下に書き込みます。  
このコードからは全てサブフレーム単位でのコントローラー入力が自由にでき、メモリの制限からも解放されます。  
このコードはサブフレーム単位でコントローラーの入力を受け取り、0xD9B2~受け取った数値を書き込むコードです。このコードを使って 593byte の第三段階のコードを書き込みます。

```
WRA1:D2EF 3E 01            ld   a,01
WRA1:D2F1 EA 00 D0         ld   (D000),a
WRA1:D2F4 F3               di
WRA1:D2F5 21 B2 D9         ld   hl,D9B2
WRA1:D2F8 3E 10            ld   a,10
WRA1:D2FA E0 00            ld   (ff00+00),a
WRA1:D2FC F0 00            ld   a,(ff00+00)
WRA1:D2FE 47               ld   b,a
WRA1:D2FF CB 30            swap b
WRA1:D301 F0 00            ld   a,(ff00+00)
WRA1:D303 A8               xor  b
WRA1:D304 22               ldi  (hl),a
WRA1:D305 47               ld   b,a
WRA1:D306 FE FD            cp   a,FD ; 第二段階終了の処理
WRA1:D308 20 0E            jr   nz,D318
WRA1:D30A FA 1E D3         ld   a,(D31E)
WRA1:D30D 3C               inc  a
WRA1:D30E EA 1E D3         ld   (D31E),a
WRA1:D311 FE 03            cp   a,03
WRA1:D313 D2 B2 D9         jp   nc,D9B2
WRA1:D316 18 E4            jr   D2FC
WRA1:D318 AF               xor  a
WRA1:D319 EA 1E D3         ld   (D31E),a
WRA1:D31C 18 DE            jr   D2FC
WRA1:D31E 00               nop
WRA1:D31F FF               rst  38 ; 第一段階終了コマンド
```

第二段階でも第一段階同様に終端文字による終了条件を付けています。第三段階のコードには`0xFD`を終端に三つつけることでコードの終わりを示しています。本来はここも 1byte で示して短く書くべきでしたが、コードの柔軟性を確保するため、ここではあえて 3byte 使って終端を示すことにしました。  
~~使っていない数値を探すのが面倒くさかったというのはここだけの話ですが…~~

#### 第三段階

第二段階で書き込んだコードを実行します。タイルの初期化や、画像・音声の出力を担当します。  
これで動画出力までの任意コード実行のセットアップが整いました。

### コードの実行

第二段階で書き込んだコードを実行します。  
このコードで行っていることは以下の通りです。

1. タイルの書き換え
1. コントローラーでの入力を VRAM に書き込む
1. コントローラーでの入力を波形メモリに書き込む
1. 書き込みを終了し、マップ、プレイヤーの名前、ポケモンのステータス等のメモリを書き換えてエンディングを見る

書き換え中は 2 と 3 をループさせて映像を出力します。画像は一画面作るのに 18\*20 マスの 360byte を必要とします。このコードでは 1 フレームにつき 180byte を取得し、2 フレームに一度画面を更新することで約 30fps を維持しています。  
また、音声については約 9709Hz で出力しています。1 サンプルにつき 4bit で構成され、1 フレームでは大体 80byte 程度を必要とします。画像データと音声データを足し合わせると 1 フレームのループで 180 + 80 = 260byte を消費し、約 16,000Hz での入力を必要とします。

さらに詳しく知りたければ[ソースコード](https://github.com/i-X-ce/PokemonYellow_BadAppleTAS/blob/main/src/asm/assembly4.asm)をご覧ください。

### エンディング

Bad Apple!!の再生を終了し、エンディングへ向かいます。  
エンディングを起こすにあたって、マップデータ、プレイヤーの名前、ポケモンのステータス、ずかんデータ、おこづかい、プレイじかん等のメモリを事前に書き換えておきます。  
エンディングはもともと ROM に存在しているプログラムを実行しています。  
これで完走です！GG！！

## 制作にあたっての工夫

この走りは、[前回の走り][4]からといろいろと工夫・改善をして制作しました。特に lsnes の資料はかなり少なく、実際に使っている人の記事などが(特に日本語のものが)ほとんど見当たらなかったので、誰かの参考になればと思い、備忘録も含めてここに軽く残しておくことにします。

### エミュレータの併用

lsnes はサブフレーム単位での入力に対応していたり、音声や VRAM に関して高い再現性をもっていたりと、とても良いエミュレータですが、TASvideo を制作するツールとしては少々癖があり、扱いづらかったです。  
そこで自分はセットアップまでのサブフレーム単位での入力を必要としない場面では BizHawk を使用することにしました。BizHawk で入力したコントローラのデータをテキストファイルに書き込み、これを lua スクリプトで読み込んでスクリプトからコントローラの入力を実行しています。幸いソフトリセットなど最低限必要な関数も用意されていたので容易に作ることができました。

```
-- luaのコード例

function line_input(line)
    local input_flg = {["A"] = false, ["B"] = false, ["s"] = false, ["S"] = false, ["R"] = false, ["L"] = false, ["U"] = false, ["D"] = false}
    for i = 1, #line do
        local char = string.sub(line, i, i)
        local button = input_dict[char]
        if button == -1 then
            input.reset()
            return
        end
        if button ~= nil then
            input_flg[char] = true
        end
    end
    for key, value in pairs(input_flg) do
        if value then
            input.set(0, input_dict[key], 1)
        else
            input.set(0, input_dict[key], 0)
        end
    end
end
```

ただ、ここで障壁になったのがエミュレータの動きの違いでした。以前の走りでは内部番号 0x00 のどうぐを選択したり捨てたりする場面が何度かありましたが、ここでフリーズするタイミングはかなりシビアでエミュレート方法に少しの違いがあるとフリーズする場合があるようです。  
実際、BizHawk では成功した入力データで lsnes を動かしてみてもフリーズを連発し、思うように動きませんでした。入力を数フレーム遅らせるなどの対応もとってみましたがこれも失敗に終わりました。また、フリーズするだけでなくどうぐ欄を移動する際、0x00 のどうぐのエミュレート方法によって名前の長さが変化するためにスクロールに要する時間が変わり、これによって大きな動きの違いが出てしまいます。初期版(r0)ではこの 0x00 のどうぐの名前が固定なので問題にはなりませんが、毎フレームの入力を 0xFFF5 に入力するのは後期版のみのため、後期版で実行するほかありません。  
試行錯誤の末、以前の走りから少しセットアップの手順を変え、0x00 のどうぐが画面内に映らないような手順を編み出しました。その結果以前のものよりもタイムが短縮されたうえ、より確実な走りができるようになりました。これがベストの方法であるとは断言できませんが、バージョンによらない確実な実行方法が考えられたことに満足しています。

### 画像

画像はタイルを最小単位とし、36\*40 のドットで表現されています。1 タイルにつき 2\*2 の 4 マスで構成され、それぞれ白,薄い灰,濃い灰,黒の 4 色を持つことができます。4 マスが 4 種類なので、タイルの種類は 4^4 の 256 種類で、これはちょうどゲームボーイのタイルの種類と合致し、VRAM 内にぴったり収めることができました。  
本当なら OnehundredthCoin 氏の[動画][2]のように元からあるタイルを使って表現したかったのですが、ポケモンのタイルは黒を使用したタイルが文字以外では少ないため、きれいに表現することが難しいと判断し、タイルごと書き直すことにしました。

動画の変換には Python の Cv2 を使用しています。変換のコードは以下の通りです。ここでは入力するテキストファイルに変換することも同時に行います。

```
# Pythonコード
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
```

画像の書き換えは OnehundredthCoin 氏の動画を参考にし、window と BG を交互に半分ずつ書き換えて 2 フレームに一度 window の表示を有効にして、約 30fps で表示しています。  
動画の内容は圧縮などはしておらず、そのまま垂れ流しで入力を行っています。圧縮の方法については OnehundredthCoin 氏と同様に差分圧縮を行おうと考えていたのですが、lsnes の仕様により入力の安定感が損なわれて 4bit 分入力がずれることがあったり、必要なデータ量がフレームごとに大きく変わったりする影響で没になりました。本当はこれも圧縮を行うべきだったと思いますが…。

### 音声

音声出力に関する知見がほとんどなく、MrWint 氏の[記事][1]を参考にしましたが、これがどうにも難しく一番苦労したポイントです。  
やっていることをかなり要約するとタイミングよく波形メモリを書き換ているというシンプルな話です。ただしこのタイミングというのはゲームボーイ内でのクロックが基準となっていて、書き換えのタイミングは正確にプログラムの長さを調整するか、何か別の手段で正確に計るしかありません。MrWint 氏がどのようにタイミングを計って書き換えていたのかは謎ですが、自分はタイマーの割り込みを調整してちょうど波形メモリの 32 サンプルが全て読まれた後に一気に 16byte 波形メモリに書き込むということをしています。この割り込みも音声の出力もクロックが単位になるのでうまいこと調整すれば完璧に音声出力と割り込みを同期させることができます。ch3 の周波数は 32 サンプル全体で`65536 / x`Hz で調整されます。今回は`x = 216`としたので、音声出力の方は`32 * 65536 / 216 = 9709`Hz になります。一方のタイマー割り込みは`262144 / y`Hz で調整され、今回は`y = 54`としたので`262144 / 54 = 4854`Hz で割り込みが入ります。割り込みが 16 回入ったタイミングであれば ch3 の周波数と一致するのでうまいこと音声の出力を調整できます。`x = 4y`の等式に当てはめると音声出力と割り込みを同期させることができるという感じです。タイマー割り込みを使う利点は画面出力と分けて実装ができる点です。MrWint 氏の[記事][1]では波形メモリの書き換えを V-Blank に同期させていると書かれていましたが、タイマー割り込みを使うことによって自ら画像と同期させる必要がなくなり、自動でタイミングを計れるようになります。これによって柔軟に音声のサンプリングレートの調整ができるようになりました(あくまで作成上の工夫であって動画の質にはまったく関与しませんが…)。  
音質は聞いてもらっての通りですが、4bit の量子化と低いサンプリングレートの影響であまりよくないです。特に低い音を出力しようとするとノイズがかなり乗ってしまったので、元の音源にハイパスフィルターをかけて低周波数の音を絞るなど、音の質を落とさざるを得ませんでした。
それに対して MrWint 氏はマスターボリュームを調整することによって 100 を超える量子化を実現し、さらにサンプリングレートも自分のものよりも倍以上高く、音質もかなり良いです。この技術は自分にはまねできませんでした。いったい何が起きているのでしょうか…。  
音に関してはまだまだ改善の余地ありです。

## 終わりに

今回の走りで以前の挑戦をはるかに上回るクオリティの動画を制作することができました。まだまだ課題は残りますが、解像度とフレームレートの向上、音声の出力が実現できたので満足です。心残りとしては動画の圧縮がうまくいかなかったことと、音声の質がかなり低いことです。どちらも最善を尽くして取り組んだつもりですが、自分の知識と技術では今のクオリティが限界でした。以前の目標であったラインは超えることができましたが、MrWint 氏と OnehundredthCoin 氏の動画のクオリティには遠く及ばなかったと少し悔しい思いです。  
自分の制作意欲を掻き立ててくれたお二人には感謝の思いを伝いたいです。また、Bad Apple!!の影絵 MV を制作されたすべての人に敬意を表します！素晴らしい動画をありがとうございます！！

[1]: https://tasvideos.org/5384S
[2]: https://tasvideos.org/8991S
[3]: https://github.com/i-X-ce/PokemonYellow_BadAppleTAS
[4]: https://www.nicovideo.jp/watch/sm42590404
