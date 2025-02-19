include "yellow_1.2_rom0.asm"

SECTION "Test",ROM0
load "ACE", wramx[$d9b2]

v_start_addr equ $9800
scene_addr equ $d000
write_cnt equ $d002 ; 書き込みカウンタ タイルのうちの何バイト目か
tile_cnt equ $d003 ; タイルカウンタ タイルのうちの何番目か 2byte
; $d004
movie_buffer equ $c100 ; ムービーバッファ

main:
    ld a, 2 ; モードの変更
    ld [scene_addr], a 

    xor a  
    ld [write_cnt], a ; 書き込みカウンタの初期化

    ld hl, $ff40
    set 4, [hl]

    call lcdc_stop
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
    jr nz, .init_hloop
    dec b
    ld de, 12 
    add hl, de
    jr nz, .init_vloop
    call lcdc_on

.mainloop
    ld hl, movie_buffer
    ld b, 0 ;y
.writeloop_y
    ld c, 0 ;x
.writeloop_x
    push bc 
    ld b, 0 
.writeloop
    push bc 

    call get_input
    ld [hli], a

    pop bc
    inc b 
    ld a, b 
    ; ld [write_cnt], a
    cp 4 
    jr c, .writeloop
    pop bc 
    inc c 
    ld a, c
    ; ld [tile_cnt + 1], a
    cp 20 
    jr c, .writeloop_x
    inc b 
    ld a, b
    ; ld [tile_cnt], a
    cp 9
    jr c, .writeloop_y

    ld hl, $8000
    ld de, movie_buffer
    ld bc, 180  
.output_vloop
    push bc 
    ld b, 4 
.output_tileloop
    push bc 
    ld a, [de]
    inc de 
    ld [hli], a
    ld [hli], a
    pop bc 
    dec b 
    jr nz, .output_tileloop
    pop bc 
    dec bc 
    ld a, c 
    or b
    jr nz, .output_vloop

.wait_next_frame ;次の画面更新まで待つ
    ldh a, [$ff00+$44]
    and a  
    jr nz, .wait_next_frame
    jr .mainloop

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