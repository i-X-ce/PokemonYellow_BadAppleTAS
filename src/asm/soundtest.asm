include "yellow_1.2_rom0.asm"

SECTION "Test",ROM0
load "ACE", wramx[$da00]

main:
    ; Hblankに合わせてFF30を書き換えてみる
    di 
    ld a, $80  
    ldh [$ff00+$1a], a
    ld a, $20 
    ldh [$ff00+$1c], a
    xor a  
    ldh [$ff00+$1b], a
    ld a, $1c ;周波数
    ldh [$ff00+$1d], a
    ld a, $87 ;周波数
    ldh [$ff00+$1e], a

.input_loop2
    xor a  
    ld bc, $20ff
.input_loop3
    push af  
.input_loop
    ldh a, [$ff00+$41]
    and $03
    jr nz, .input_loop
    ldh a, [$ff00+$44]
    cp a, c
    jr z, .input_loop
    ld c, a 
    pop af
    bit 0, b
    jr nz, .input_skp 
    push af 
    xor a  
    ldh [$ff00+$1a], a
    pop af 
    push af 
    ldh [$ff00+$30], a
    ld a, $80 
    ldh [$ff00+$1a], a
    pop af
    add $11
.input_skp
    dec b
    jr nz, .input_loop3 
    jr .input_loop2



;     ; カウント用
;     di 
;     xor a  
;     ldh [$ff00+$1a], a
;     ld a, $20 
;     ldh [$ff00+$1c], a
;     xor a  
;     ldh [$ff00+$1b], a
;     ld a, $1c
;     ldh [$ff00+$1d], a
;     ld a, $87
;     ldh [$ff00+$1e], a

;     xor a 
;     ld bc, $1030
; .input_loop 
;     ld [$ff00+c], a
;     add $11
;     inc c 
;     dec b 
;     jr nz, .input_loop
;     ld a, $80
;     ldh [$ff00+$1a], a
;     ldh a, [$ff00+$1e]
;     or $80
;     ldh [$ff00+$1e], a

;     ld hl, .cnt
; .read_loop
;     ldh a, [$ff00+$30]
;     cp b  
;     jr z, .read_loop
;     ld b, a
;     inc [hl]
;     ldh a, [$ff00+$44]
;     and a  
;     jr nz, .reset
;     ld [hl], a
; .reset
;     jr .read_loop
; .cnt 
;     db 0



;     di 
;     ld a, $80 
;     ldh [$ff00+$1a], a
;     ld a, $20 
;     ldh [$ff00+$1c], a
;     xor a  
;     ldh [$ff00+$1b], a
;     ld a, $ff
;     ldh [$ff00+$1d], a
;     ld a, $87
;     ldh [$ff00+$1e], a

; .wait_hblank 
;     ldh a, [$ff00+$41]
;     and $03
;     cp $03
;     jr nz, .wait_hblank
;     ld a, $80 
;     ldh [$ff00+$1e], a

;     xor a 
;     ld b, a 
; .input_cloop
;     ld c, $30 
; .input_loop
;     ld a, b 
;     ld [$ff00+c], a
;     inc a
;     ld b, a   
;     inc c 

; .wait_hblank2 
;     ldh a, [$ff00+$41]
;     and $03
;     cp $03
;     jr nz, .wait_hblank2
;     ldh a, [$ff00+$44]
;     cp d  
;     jr z, .wait_hblank2
;     ld d, a 
;     ld a, c
;     cp $40
;     jr nc, .input_cloop
;     jr .input_loop
    


; .current_addr
;     db 0, 0

; .current_wave
;     db 0


;     di 
;     ld a, $80 
;     ldh [$ff00+$1a], a
;     ld a, $20 
;     ldh [$ff00+$1c], a
;     xor a  
;     ldh [$ff00+$1b], a
;     ld a, $c7
;     ldh [$ff00+$1d], a
;     ld a, $87
;     ldh [$ff00+$1e], a

; .wait_hblank 
;     ldh a, [$ff00+$41]
;     and $03
;     cp $03
;     jr nz, .wait_hblank
;     ld a, $80 
;     ldh [$ff00+$1e], a

;     ld hl, $a000 
; .input_loop16
;     ld bc, $1030 
; .input_loop
;     ld a, [hli] 
;     ld [$ff00+c], a
;     inc c 
;     dec b  
;     jr nz, .input_loop
    
;     ld b, $10
;     ldh a, [$ff00+$44]
;     ld d, a
; .wait_hblank2 
;     ldh a, [$ff00+$41]
;     and $03
;     cp $03
;     jr nz, .wait_hblank2
;     ldh a, [$ff00+$44]
;     cp d  
;     jr z, .wait_hblank2
;     ld d, a 
;     dec b 
;     jr nz, .wait_hblank2
;     ld a, h 
;     cp $b0
;     jr nc, .wait_hblank
;     jr .input_loop16



; .current_addr
;     db 0, 0

; .current_wave
;     db 0
    
;     di 
;     xor a  
;     ldh [$ff00+$1a], a
;     ld a, $00 
;     ldh [$ff00+$11], a
;     ldh [$ff00+$16], a
;     ld a, $f0
;     ldh [$ff00+$12], a
;     ldh [$ff00+$17], a
;     ld a, $00 
;     ldh [$ff00+$13], a
;     ldh [$ff00+$18], a
;     ld a, $84
;     ldh [$ff00+$14], a
; .mainloop
;     ld hl, $ff14
;     set 7, [hl]
;     jr .mainloop

    

;     ld a, $00 
;     ldh [$ff00+$13], a
;     ldh [$ff00+$18], a
; .mainloop
;     ld a, $84
;     ldh [$ff00+$14], a

;     ld d, a 
;     ld bc, 170
; .ch2wait_loop
;     dec bc 
;     ld a, c
;     or b  
;     jr nz, .ch2wait_loop
;     ld a, d
;     ldh [$ff00+$19], a

;     ld bc, $0000 
; .wait_loop
;     dec bc 
;     ld a, c
;     or b
;     jr nz, .wait_loop

;     jr .mainloop

;     di 
;     ld a, $80 
;     ldh [$ff00+$1a], a
;     ld a, $20 
;     ldh [$ff00+$1c], a
;     xor a  
;     ldh [$ff00+$1b], a
;     ld a, $ff
;     ldh [$ff00+$1d], a
;     ld a, $87
;     ldh [$ff00+$1e], a

; .start
;     ld hl, $a000
; .input_loop2
;     ld bc, $1030
; .input_loop
;     xor a  
;     ldh [$ff00+$1a], a

;     ld a, [hli]
;     cp $ff
;     jr z, .start
;     ld [$ff00+c], a
;     inc c 
;     dec b 
;     jr nz, .input_loop
;     ld a, $80
;     ldh [$ff00+$1a], a
;     ld bc, $0100
; .wait_loop
;     dec bc
;     ld a, c 
;     or b 
;     jr nz, .wait_loop
;     jr .input_loop2

    