include "yellow_1.2_rom0.asm"

SECTION "Test",ROM0
load "ACE", wramx[$da00]


main:
    ld hl, $9800
    ld bc, $400
.loop
    ld a, [hl]
    inc a 
    ld [hli], a
    dec bc 
    ld a, b
    or c
    jr nz, .loop
    jr main
