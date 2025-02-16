include "yellow_1.2_rom0.asm"

SECTION "Test",ROM0
load "ACE", wramx[$d9b2]

v_start_addr equ $9800
scene_addr equ $d000
write_cnt equ $d002 ; 書き込みカウンタ

main:
    ld a, 2 ; モードの変更
    ld [scene_addr], a 

    xor a  
    ld [write_cnt], a ; 書き込みカウンタの初期化

    ld hl, v_start_addr ; VRAMの初期化
    ld b, 18 
.init_vloop
    ld c, 20 
.init_hloop
    ld [hli], a
    inc a 
    cp 180 
    jr c, .skp180
    xor a  
.skp180
    dec c 
    jr nz, .init_hlooploop
    dec b
    ld de, 11 
    add hl, de
    jr nz. .init_vloop


; 入力を取る
get_input:
    ld a, $10
    ldh [$ff00+0], a
    ldh a, [$ff00+0]
    cpl  
    and $f
    ld b, a 
    ld a, $20
    ldh [$ff00+0], a
    ldh a, [$ff00+0]
    cpl  
    and $f
    swap a 
    or b
    ret  