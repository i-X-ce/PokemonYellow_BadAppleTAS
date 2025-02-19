include "yellow_1.2_rom0.asm"

SECTION "Test",ROM0
load "ACE", wramx[$d9b2]

BG_addr equ $9800
WIN_addr equ $9c00
scene_addr equ $d000
write_addr equ $d001 ; 書き込み中のアドレスを保存 2byte
write_addr_high equ $d002

write_line equ 9 ; 1frameに書き込む行数

main:
    ld a, 2 ; モードの変更
    ld [scene_addr], a 

    xor a  
    ldh [$ff00+$4a], a

    ld hl, $ff40
    set 4, [hl]

    ld a, $10
    ldh [$ff00+0], a

    call lcdc_stop
    call init_tile
    call lcdc_on

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
    ld b, write_line
    .input_vloop
    ld c, 20
.input_hloop
    push bc 
    call get_input
    ld b, a 
.input_wait 
    ldh a, [$ff00+$41]
    and $03 
    cp 3
    jr nc, .input_wait
    ld [hl], b
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
    jr nz, .write_save
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
.loop
    ldh a, [$ff00+$44]
    and a  
    jr nz, .loop
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
get_input:
    ldh a, [$ff00+0]
    ld b, a  
    swap b 
    ldh a, [$ff00+0]
    xor b
    ret  