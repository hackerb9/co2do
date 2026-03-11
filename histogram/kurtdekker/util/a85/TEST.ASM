* Kurt W. Dekker
* Dated 08/22/90
* TEST.ASM
; This program is a test program for the new assembler

	org	58800
update	equ	62750
comment	equ	123;yabo!

	extrn	kurt

label:
	nop
	ld	a,b
	ld	c,(hl)
	ldir
	push	af
	pop	hl
	jmp	nz,label
	ret	nz
data	dfm	Hello...
kurt	dm	YYY
; comment whoo-ya!
