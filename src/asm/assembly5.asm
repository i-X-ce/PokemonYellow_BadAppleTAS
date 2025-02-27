; 音声入力に対応したバージョン
; TASproject/inputprogram.txtにTAS変換(半入力Bボタン反転ABSs)して書き込む

include "yellow_1.2_rom0.asm"

SECTION "Test",ROM0
load "ACE", wramx[$d9b2]

BG_addr equ $9800
WIN_addr equ $9c00
soundfreq_upper equ $07
soundfreq_lower equ $1c

sound_buffer equ $c100 ; サウンドバッファ

scene_addr equ $d000
write_addr equ $d001 ; 書き込み中のアドレスを保存 2byte
write_addr_high equ $d002
write_mode equ $d003 ; 書き込みモード 0:画像, 1:音声
sound_write_cnt equ $d004 ; サウンド書き込みカウンタ
sound_read_cnt equ $d005 ; サウンド読み込みカウンタ
lag_frame equ $d006 ; frameの遅延
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
    ld [sound_write_cnt], a
    ld [sound_read_cnt], a
    ld [lag_frame], a
    ld a, $c7 ; 262144 / 57 Hz (2lineに一回)
    ldh [$ff00+$06], a ; タイマー調整
    ld a, $05 
    ldh [$ff00+$07], a ; タイマー制御
    ld a, soundfreq_lower 
    ldh [$ff00+$1d], a ; サウンド3周波数
    ld a, $80 | soundfreq_upper
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
    ld c, 0 
.init_sound ; サウンドバッファを初期化
    ldh a, [$ff00+0]
    ld b, a  
    swap b 
    ldh a, [$ff00+0]
    xor b
    ld [hl], a
    inc l
    dec c 
    jr nz, .init_sound

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

.wait_first_frame ; 最初のフレームを待つ
    ldh a, [$ff00+$44]
    and a  
    jr nz, .wait_first_frame

    xor a  
    ld [write_mode], a

.mainloop
    ldh a, [$ff00+0]
    ld b, a  
    swap b 
    ldh a, [$ff00+0]
    xor b
    cp $ff 
    jr z, .input_end
    ld l, a 
    ldh a, [$ff00+0]
    ld b, a  
    swap b 
    ldh a, [$ff00+0]
    xor b
    ld h, a 
    ldh a, [$ff00+0]
    ld b, a  
    swap b 
    ldh a, [$ff00+0]
    xor b
    ld b, a 
.input_wait
    push bc 
    call step_sound
    pop bc
    ld [hl], b 
    ldh a, [$ff00+$41]
    ld [hl], b
    and $03
    cp $03 
    jr nc, .input_wait
    ldh a, [$ff00+$44]
    cp $98
    jr nz, .lagskp
    ld a, 1 
    ld [lag_frame], a  
.lagskp
    jr .mainloop

.input_end
    ld a, [lag_frame]
    and a  
    call z, wait_next_frame
    call wait_next_frame
    xor a 
    ld [lag_frame], a
    ldh a, [$ff00+$40]
    xor $20
    ldh [$ff00+$40], a
    jr .mainloop

wait_next_frame: ;次の画面更新まで待つ
    ld a, 1 
    ld [write_mode], a
    ld a, [sound_write_cnt]
    ld l, a 
    ld h, high(sound_buffer)
.loop
    ld a, [sound_read_cnt]
    cp l
    jr z, .sound_input_skp ; 読み込みに追いついたらストップ
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
    and a  
    jr nz, .loop
    xor a  
    ld [write_mode], a
    ld a, l 
    ld [sound_write_cnt], a
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
