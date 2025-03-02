; 圧縮した画像データをバッファに格納するバージョン 色の反転も追加
; TASproject/inputprogram.txtにTAS変換(半入力Bボタン反転ABSs)して書き込む

include "yellow_1.2_rom0.asm"

SECTION "Test",ROM0
load "ACE", wramx[$d9b2]

BG_addr equ $9800
WIN_addr equ $9c00
soundfreq_upper equ $07
soundfreq_lower equ $1c

sound_buffer equ $c100 ; サウンドバッファ
image_buffer equ $a000 ; 画像バッファ
image_buffer_size equ $2000 ; 画像バッファのサイズ

scene_addr equ $d000
; write_addr equ $d001 ; 書き込み中のアドレスを保存 2byte
; write_addr_high equ $d002
write_mode equ $d003 ; 書き込みモード 0:画像, 1:音声
sound_write_cnt equ $d004 ; サウンド書き込みカウンタ
sound_read_cnt equ $d005 ; サウンド読み込みカウンタ
image_write_addr equ $d006 ; 画像書き込みアドレス
image_write_addr_high equ $d007
image_read_addr equ $d008 ; 画像読み込みアドレス
image_read_addr_high equ $d009
frame_cnt equ $d00a ; フレームカウンタ
next_window equ $d00b ; 次のウィンドウのフラグ
next_reverse equ $d00c ; 次のパレット反転

image_data_size_ipf equ 200 ; 1frameに書き込むデータの数
input_ly equ 80 ; 入力に移行するライン


main:
    ld a, 2 ; モードの変更
    ld [scene_addr], a 

    xor a  
    ldh [$ff00+$4a], a ; ウィンドウY座標
    ldh [$ff00+$12], a ; サウンド1エンベローブ
    ldh [$ff00+$17], a ; サウンド2エンベローブ
    ldh [$ff00+$21], a ; サウンド4エンベローブ
    ldh [$ff00+$1b], a ; サウンド3サウンド長
    ldh [$ff00+$05], a ; タイマーカウンタ
    ldh [$ff00+$0f], a ; 割り込みフラグ
    ld [sound_write_cnt], a
    ld [sound_read_cnt], a
    ld [frame_cnt], a
    ld a, $c7 ; 262144 / 57 Hz (2lineに一回)
    ldh [$ff00+$06], a ; タイマー調整
    ld a, $05 
    ldh [$ff00+$07], a ; タイマー制御
    ld a, soundfreq_lower 
    ldh [$ff00+$1d], a ; サウンド3周波数
    ld a, $80 | soundfreq_upper
    ldh [$ff00+$1e], a ; サウンド3周波数

    ; SRAMを開く
    ld a, $0a
    ld [$0000], a
    ld a, $01 
    ld [$6000], a 
    dec a 
    ld [$4000], a 

    ld hl, $ff40
    set 4, [hl]

    ld a, $10
    ldh [$ff00+0], a

    call lcdc_stop
    call init_tile
    call lcdc_on

    xor a  
    ld [write_mode], a
    ld hl, image_buffer
    ld de, image_buffer_size - $200
.init_image ; 画像バッファに読み込み
    ldh a, [$ff00+0]
    ld b, a  
    swap b 
    ldh a, [$ff00+0]
    xor b
    ld [hli], a
    dec de 
    ld a, e
    or d
    jr nz, .init_image
    ld a, l     
    ld [image_write_addr], a
    ld a, h
    ld [image_write_addr_high], a
    ld a, low(image_buffer)
    ld [image_read_addr], a
    ld a, high(image_buffer)
    ld [image_read_addr_high], a
    


    ld a, 1
    ld [write_mode], a
    ld hl, sound_buffer
    ld c, 0 
.init_sound ; サウンドバッファに読み込み
    ldh a, [$ff00+0]
    ld b, a  
    swap b 
    ldh a, [$ff00+0]
    xor b
    ld [hl], a
    inc l
    dec c 
    jr nz, .init_sound

    xor a  
    ld [write_mode], a

    ld hl, BG_addr
    ld bc, $800
.init_vram ; VRAMを初期化
    ld a, $ff 
    ld [hl], a
    ldh a, [$ff00+$41]
    and $03
    cp $02
    jr nc, .init_vram
    inc hl
    dec bc 
    ld a, c 
    or b
    jr nz, .init_vram


.mainloop
.wait_first_frame ; 最初のフレームを待つ
    call step_sound
    ldh a, [$ff00+$44]
    and a  
    jr nz, .wait_first_frame

    ld hl, frame_cnt
    inc [hl]


    ; 画像をバッファから読み込み
    ld hl, image_read_addr
    ld a, [hli]
    ld h, [hl]
    ld l, a
.image_read_loop
    ld a, h 
    cp high(image_buffer + image_buffer_size)
    jr c, .image_read_over_skp ; バッファサイズを超えてたら初期位置に戻す
    ld hl, image_buffer
.image_read_over_skp 
    ld a, [hli]
    cp $22 
    jr c, .image_read_end ; 00-20までが画面切り替えコマンド
    ld d, a 
    ld a, [hli]
    ld e, a
    ld a, [hli]
    ld b, a
    push hl 
    ld h, d 
    ld l, e

.image_read_write_wait 
    ld [hl], b
    ldh a, [$ff00+$41]
    ld [hl], b
    and $03
    cp $03 
    jr nc, .image_read_write_wait
    call step_sound
    pop hl
    ldh a, [$ff00+$44]
    cp input_ly - 2 
    jr c, .image_read_loop
    jr .image_read_save_addr

.image_read_end
    dec hl 
    ld b, a  
    ld a, [frame_cnt]
    bit 0, a 
    jr nz, .image_read_save_addr ; 奇数フレームのみ切り替えが起こる
    inc hl 
    ld a, b 
    ld [next_window], a
    bit 0, a  
    ld a, $e4
    jr z, .image_read_reverse_skp
    cpl  
.image_read_reverse_skp 
    ld [next_reverse], a ; パレット反転
.image_read_save_addr
    ld a, l 
    ld [image_read_addr], a
    ld a, h 
    ld [image_read_addr_high], a
    


    ; 画像をバッファに入力
.image_input
    xor a  
    ld [write_mode], a
    ld hl, image_write_addr
    ld a, [hli]
    ld h, [hl]
    ld l, a
.image_input_loop
    ld a, h 
    cp high(image_buffer + image_buffer_size)
    jr c, .image_input_digit_skp ; バッファサイズを超えてたら初期位置に戻す
    ld hl, image_buffer
.image_input_digit_skp
    ld a, [image_read_addr_high]
    cp h  
    jr z, .image_input_end2 ; 追いつきそうだったら終了 256の範囲内で読み込みに追いつかれる可能性があるので注意
    ldh a, [$ff00+0]
    ld b, a  
    swap b 
    ldh a, [$ff00+0]
    xor b
    ld [hli], a
    cp $22
    jr c, .image_input_end
    ldh a, [$ff00+0]
    ld b, a  
    swap b 
    ldh a, [$ff00+0]
    xor b
    ld [hli], a
    ldh a, [$ff00+0]
    ld b, a  
    swap b 
    ldh a, [$ff00+0]
    xor b
    ld [hli], a
.image_input_end ; 終了判定
    call step_sound
    ldh a, [$ff00+$44]
    cp input_ly
    jr c, .image_input_loop
.image_input_end2 ; 本当に終了する
    ld a, l 
    ld [image_write_addr], a
    ld a, h 
    ld [image_write_addr_high], a 

    ; 速すぎる場合1ライン待つ
; .wait_one_line
;     ldh a, [$ff00+$44]
;     cp $97
;     jr z, .wait_one_line

    ; サウンドの書き込み
.sound_input
    ld a, 1 
    ld [write_mode], a
    ld a, [sound_write_cnt]
    ld l, a 
    ld h, high(sound_buffer)
.sound_input_loop
    ld a, [sound_read_cnt]
    cp l  
    jr z, .sound_input_skp
    ldh a, [$ff00+0]
    ld b, a  
    swap b 
    ldh a, [$ff00+0]
    xor b
    ld [hl], a
    inc l
.sound_input_skp
    call step_sound
    ldh a, [$ff00+$44]
    cp $97 
    jr c, .sound_input_loop
    ld a, l
    ld [sound_write_cnt], a

    ; ウィンドウの切り替え
    ld a, [next_window]
    ld b, a 
    ldh a, [$ff00+$40]
    and $df 
    or b  
    ldh [$ff00+$40], a
    ld a, [next_reverse]
    ldh [$ff00+$47], a
    jp .mainloop


; タイルを初期化する
init_tile:
    ld hl, $8000
    xor a
.loop
    push af 
    call .core 
    pop af 
    push af 
    swap a 
    call .core 
    pop af 
    inc a 
    jr nz, .loop
    ret  

.core
    call init_tile_format    
    ld d, 4
.dloop
    ld [hl], b
    inc hl 
    ld [hl], c
    inc hl 
    dec d 
    jr nz, .dloop 
    ret  

;aの下桁の値をタイル用にフォーマットしてbcに返す
init_tile_format:
    push hl 
    push af 
    call .core
    ld b, [hl]
    pop af 
    rrca 
    call .core 
    ld c, [hl]
    pop hl 
    ret 
.core 
    and $05
    ld hl, init_tile_format_table
    add l  
    ld l, a 
    ld a, 0 
    adc h  
    ld h, a 
    ret  

init_tile_format_table:
    db $00, $0f, $00, $00, $f0, $ff


; 入力を取る
; get_input:
;     ldh a, [$ff00+0]
;     ld b, a  
;     swap b 
;     ldh a, [$ff00+0]
;     xor b
;     ret  


; サウンドを鳴らす hlを保持
step_sound:
    ldh a, [$ff00+$0f]
    bit 2, a 
    ret z
    xor a  
    ldh [$ff00+$0f], a
    ld a, [.sound_cnt]
    dec a 
    ld [.sound_cnt], a
    ret nz 
    ldh [$ff00+$1a], a
    ld a, $10 
    ld [.sound_cnt], a
    ld bc, $1030
    
    ld a, [sound_read_cnt]
    ld e, a 
    ld d, high(sound_buffer)
.input_loop 
    ld a, [de]
    inc e 
    ld [$ff00+c], a
    inc c 
    dec b 
    jr nz, .input_loop
    ld a, e 
    ld [sound_read_cnt], a
    ld a, $80 | soundfreq_upper
    ldh [$ff00+$1a], a
    ldh [$ff00+$1e], a
    ret

.sound_cnt
    db $10 

end_cmd: ; 終端のコマンド
    db $fd, $fd, $fd
