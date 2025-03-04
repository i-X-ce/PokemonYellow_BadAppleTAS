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

    ld a, $10
    ldh [$ff00+0], a

    call lcdc_stop
    call init_tile
    ld hl, v_start_addr ; VRAMの初期化
    ld b, 18 
.init_vloop
    ld c, 20 
.init_hloop
    ld [hli], a
    inc a 
    dec c 
    jr nz, .init_hloop
    dec b
    ld de, 12 
    add hl, de
    jr nz, .init_vloop
    call lcdc_on

.mainloop
    ld hl, movie_buffer

    ld bc, 360 
.inputloop
    push hl 
    push bc 
    call get_input
    pop bc 
    pop hl 
    ld [hli], a
    dec bc 
    ld a, c 
    or b 
    jr nz, .inputloop

    ld hl, v_start_addr
    ld de, movie_buffer
    ld b, 18 
.output_vloop
    ld c, 20 
.output_hloop
    push bc 
.output_wait 
    ldh a, [$ff00+$41]
    and $03 
    cp 2
    jr nc, .output_wait
    ld a, [de]
    inc de 
    ld [hli], a
    pop bc 
    dec c 
    jr nz, .output_hloop
    ld a, 12 
    add l 
    ld l, a
    ld a, 0 
    adc h
    ld h, a
    dec b
    jr nz, .output_vloop

.wait_next_frame ;次の画面更新まで待つ
    ldh a, [$ff00+$44]
    and a  
    jr nz, .wait_next_frame
    jr .mainloop


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