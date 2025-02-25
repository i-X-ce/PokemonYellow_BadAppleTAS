; 最初に入力するプログラム
; TAS入力用に変換してinput.txtの下に追加する
include "yellow_1.2_rom0.asm"

SECTION "Test",ROM0
load "ACE", wramx[$d2ef]

scene_addr equ $d000
write_cnt equ $d001

first_addr equ $d9b2

main:
    ld a, 1
    ld [scene_addr],a
    di  
    ld hl, first_addr
    ld d, 0
.input_loop
    ld a,10
    ldh [$ff00+0], a
    ldh a, [$ff00+0]
    cpl  
    and a, $0F
    ld b, a
    ld a, 20
    ldh [$ff00+0], a
    ldh a, [$ff00+0]
    cpl  
    and a, $0F
    swap a
    or b
    ld [hli], a
    ld b, a 
    inc d
    ld a, d
    ld [write_cnt], a

    ld a, d 
    cp $fd 
    jr nz, .endskp
    ld a, [.end_cnt]
    inc a 
    ld [.end_cnt], a
    cp 3 
    jp nc, first_addr
.endskp
    xor a  
    ld [.end_cnt], a
    jr .input_loop


.end_cnt 
    db 0
.end_cmd
    db $ff ; 終端のFF