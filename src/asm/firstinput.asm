; 最初に入力するプログラム
; TAS入力用に変換してTASproject/input.txtの下に追加する
include "yellow_1.2_rom0.asm"

SECTION "Test",ROM0
load "ACE", wramx[$d2ef]

scene_addr equ $d000
; write_cnt equ $d001

first_addr equ $d9b2

main:
    ld a, 1
    ld [scene_addr],a
    di  
    ld hl, first_addr
    ld a,$10
    ldh [$ff00+0], a
.input_loop
    ldh a, [$ff00+0]
    ld b, a  
    swap b 
    ldh a, [$ff00+0]
    xor b
    ld [hli], a
    ld b, a 

    cp $fd 
    jr nz, .endskp
    ld a, [.end_cnt]
    inc a 
    ld [.end_cnt], a
    cp 3 
    jp nc, first_addr
    jr .input_loop
.endskp
    xor a  
    ld [.end_cnt], a
    jr .input_loop

.end_cnt 
    db 0
.end_cmd
    db $ff ; 終端のFF