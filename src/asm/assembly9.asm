; 4をもとにサウンドバッファを増築(うまくいかず)
; TASproject/inputprogram.txtにTAS変換(半入力Bボタン反転ABSs)して書き込む

include "yellow_1.2_rom0.asm"

SECTION "Test",ROM0
load "ACE", wramx[$d9b2]

BG_addr equ $9800
WIN_addr equ $9c00
soundfreq equ $717
interruptfreq equ $c6

sound_buffer equ $c100 ; サウンドバッファ
sound_buffer_size equ 8 * $100 ; サウンドバッファのサイズ(必ず256の倍数)

scene_addr equ $d000
write_addr equ $d001 ; 書き込み中のアドレスを保存 2byte
write_addr_high equ $d002
write_mode equ $d003 ; 書き込みモード 0:画像, 1:音声
sound_write_cnt equ $d004 ; サウンド書き込みカウンタ
sound_write_cnt_high equ $d005 
sound_read_cnt equ $d006 ; サウンド読み込みカウンタ
sound_read_cnt_high equ $d007 
write_line equ 9 ; 1frameに書き込む行数

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
    ld a, interruptfreq ; 262144 / 57 Hz (2lineに一回)
    ldh [$ff00+$06], a ; タイマー調整
    ld a, $05 
    ldh [$ff00+$07], a ; タイマー制御
    ld a, low(soundfreq)
    ldh [$ff00+$1d], a ; サウンド3周波数
    ld a, $80 | high(soundfreq)
    ldh [$ff00+$1e], a ; サウンド3周波数

    ld hl, $ff40
    set 4, [hl]

    ld a, $10
    ldh [$ff00+0], a

    call lcdc_stop
    call init_tile
    call lcdc_on

    ld a, 1
    ld [write_mode], a
    ld hl, sound_buffer
    ld de, sound_buffer_size
.init_sound ; サウンドバッファを初期化
    ldh a, [$ff00+0]
    ld b, a  
    swap b 
    ldh a, [$ff00+0]
    xor b
    ld [hli], a
    dec de
    ld a, e 
    or d 
    jr nz, .init_sound
    ld a, low(sound_buffer)
    ld [sound_write_cnt], a
    ld [sound_read_cnt], a
    ld a, high(sound_buffer)
    ld [sound_write_cnt_high], a
    ld [sound_read_cnt_high], a

    xor a  
    ld [write_mode], a

.mainloop
    ld hl, BG_addr
    ldh a, [$ff00+$40]
    bit 5, a 
    jr nz, .WIN_skp
    ld hl, WIN_addr
.WIN_skp
    jr .input_start

    ; 途中から始める場合
    .mainloop_
    ld a, [write_addr]
    ld l, a 
    ld a, [write_addr_high]
    ld h, a

.input_start
    .wait_first_frame ; 最初のフレームを待つ
    call step_sound
    ldh a, [$ff00+$44]
    cp $10  
    jr nc, .wait_first_frame

    ld b, write_line
    .input_vloop
    ld c, 20
.input_hloop
    push bc 
    ldh a, [$ff00+0]
    ld b, a  
    swap b 
    ldh a, [$ff00+0]
    xor b
    ld b, a  
.input_wait 
    ld [hl], b
    ldh a, [$ff00+$41]
    ld [hl], b
    and $03 
    cp 3
    jr nc, .input_wait
    call step_sound
    inc hl 
    pop bc
    dec c 
    jr nz, .input_hloop
    ld de, 12
    add hl, de
    dec b
    jr nz, .input_vloop

    ; 書き込みが終了したか判定
    ld a, l 
    cp $40
    jr c, .write_save
    ld a, h
    cp $9a
    jr z, .write_switch
    cp $9e
    jr z, .write_switch
    jr .write_save

.write_switch
    ; 書き込み終了時の処理
    call wait_next_frame
    ldh a, [$ff00+$40]
    xor $20
    ldh [$ff00+$40], a
    jr .mainloop

.write_save
    ; 書き込み場所を途中保存
    ld a, l 
    ld [write_addr], a
    ld a, h 
    ld [write_addr_high], a
    call wait_next_frame
    jr .mainloop_


wait_next_frame: ;次の画面更新まで待つ
    ld a, 1 
    ld [write_mode], a
    ld a, [sound_write_cnt_high]
    ld h, a 
    ld a, [sound_write_cnt]
    ld l, a
.loop
    ld a, h  
    cp high(sound_buffer + sound_buffer_size)
    jr c, .over_skp
    ld hl, sound_buffer; バッファサイズを超えていたら戻す
.over_skp 
    ld a, [sound_read_cnt_high]
    cp h  
    jr z, .sound_input_skp ; 読み込みに追いついたらストップ
.catch_up_skp
    ldh a, [$ff00+0]
    ld b, a  
    swap b 
    ldh a, [$ff00+0]
    xor b
    ld [hli], a
.sound_input_skp
    call step_sound
    ldh a, [$ff00+$44]
    cp $10
    jr c, .loop_skp ; step_soundの割り込みで処理が伸びた場合はスキップ
    cp $97
    jr c, .loop
.loop_skp
    xor a  
    ld [write_mode], a
    ld a, l 
    ld [sound_write_cnt], a
    ld a, h
    ld [sound_write_cnt_high], a
    ret 


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
    ld a, [sound_read_cnt_high]
    ld d, a
    ld a, [sound_read_cnt]
    ld e, a 

.input_loop 
    ld a, d  
    cp high(sound_buffer + sound_buffer_size)
    jr c, .over_skp
    ld de, sound_buffer
.over_skp
    ld a, [de]
    inc de 
    ld [$ff00+c], a
    inc c 
    dec b 
    jr nz, .input_loop
    ld a, e 
    ld [sound_read_cnt], a
    ld a, d 
    ld [sound_read_cnt_high], a
    ld a, $80 | high(soundfreq)
    ldh [$ff00+$1a], a
    ldh [$ff00+$1e], a
    ret

.sound_cnt
    db $10 

end_cmd: ; 終端のコマンド
    db $fd, $fd, $fd
