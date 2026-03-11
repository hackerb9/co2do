;
;  Copyright (C) 2004, Kurt W Dekker, PLBM Games, kwd@plbm.com, www.plbm.com
;
;  This program is free software; you can redistribute it and/or modify
;  it under the terms of the GNU General Public License as published by
;  the Free Software Foundation; either version 2 of the License, or
;  (at your option) any later version.
;
;  This program is distributed in the hope that it will be useful,
;  but WITHOUT ANY WARRANTY; without even the implied warranty of
;  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;  GNU General Public License for more details.
;
;  You should have received a copy of the GNU General Public License
;  along with this program; if not, write to the Free Software
;  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
;
;
;**********************************************************************************************************************
;
; Author:	Kurt W. Dekker
; Started:	05/20/92
; Updated:	05/20/92
; Filename:	BALLBNCE.ASM
;
; Description:	Bouncing balls for the TRS-80 Model 100
;
; Explanation:	I felt the urgent desire to HACK, and HACK I did!  I came out
;		with some very tight plot code, tighter than I'd ever done in
;		high school with this silly 8085 processor.  Now I can just
;		keep building on this module, just for funsies.
;
;**********************************************************************************************************************
;

numballs	equ	25
ballsize	equ	8
update		equ	62750

		org	59000

		call	cls

		call	initall

mainloop:
		mov	hl,60672
		inc	(hl)
		call	doballs

		call	update

		jp	mainloop

cls:
		mov	hl,60672
		mov	bc,2048
clsloop:
		mov	(hl),0
		inc	hl
		dec	bc
		mov	a,b
		or	c
		jp	nz,clsloop

		ret

initall:
		call	initballs
		ret

initballs:
		mov	a,numballs
		mov	[counter1],a
		mov	hl,dataarea
		mov	[pointer1],hl
initloop:
		mov	hl,[pointer1]
again1:
		call	rnd
		cmp	240
		jp	nc,again1
		mov	(hl),a
		inc	hl
again1a:
		call	rnd
		and	63
		cmp	55
		jp	nc,again1a
		mov	(hl),a
		inc	hl
again2:
		call	rnd
		and	7
		sub	3
		jp	z,again2
		mov	(hl),a
		inc	hl
again3:
		call	rnd
		and	7
		sub	3
		jp	z,again3
		mov	(hl),a
		inc	hl

; now choose a shape for this object...
		call	rnd
		and	3
		mov	e,a
		mov	d,0
		push	hl
		mov	hl,xlimitlist
		add	hl,de
		mov	a,(hl)
		pop	hl
		mov	(hl),a		; store X limit
		inc	hl
		push	hl
		mov	hl,ylimitlist
		add	hl,de
		mov	a,(hl)
		pop	hl
		mov	(hl),a		; store Y limit
		inc	hl
		push	hl
		mov	hl,shapelist
		add	hl,de
		add	hl,de
		xchg	de,hl
		pop	hl
		mov	a,(de)
		mov	(hl),a
		inc	hl
		inc	de
		mov	a,(de)
		mov	(hl),a

		mov	hl,[pointer1]
		mov	de,ballsize
		add	hl,de
		mov	[pointer1],hl
		mov	hl,counter1
		dec	(hl)
		jp	nz,initloop

		ret

doballs:
		mov	a,numballs
		mov	[counter1],a
		mov	hl,dataarea
		mov	[pointer1],hl
doballloop:
		mov	hl,[pointer1]
		mov	a,(hl)
		inc	hl
		mov	b,(hl)
		inc	hl
		inc	hl
		inc	hl
		push	af
		inc	hl
		inc	hl
		mov	a,(hl)		; low-order byte of shape address
		inc	hl
		mov	h,(hl)
		mov	l,a		; hl now points to shape
		pop	af
		call	eraseshape

; now calculate movement, first on X axis
		mov	hl,[pointer1]
		mov	a,(hl)
		inc	hl
		inc	hl
		add	(hl)
		inc	hl
		inc	hl
		cmp	(hl)
		jp	c,okayx
		dec	hl
		dec	hl
		mov	a,(hl)
		cpl			; reverse X movement
		inc	a
		mov	(hl),a
		dec	hl
		dec	hl
		mov	a,(hl)
okayx:
		mov	hl,[pointer1]
		mov	(hl),a

; and now the Y-axis
		mov	hl,[pointer1]
		inc	hl
		mov	a,(hl)
		inc	hl
		inc	hl
		add	(hl)
		inc	hl
		inc	hl
		cmp	(hl)
		jp	c,okayy
		dec	hl
		dec	hl
		mov	a,(hl)
		cpl			; reverse X movement
		inc	a
		mov	(hl),a
		dec	hl
		dec	hl
		mov	a,(hl)
okayy:
		mov	hl,[pointer1]
		inc	hl
		mov	(hl),a

; now plot the shape back on the screen.
		mov	hl,[pointer1]
		mov	a,(hl)
		inc	hl
		mov	b,(hl)
		inc	hl
		inc	hl
		inc	hl
		push	af
;		mov	c,(hl)		; get X limit
		inc	hl
;		mov	d,(hl)		; get Y limit
		inc	hl
		mov	a,(hl)		; low-order byte of shape address
		inc	hl
		mov	h,(hl)
		mov	l,a		; hl now points to shape
		pop	af
		call	plotshape

		mov	hl,[pointer1]
		mov	de,ballsize
		add	hl,de
		mov	[pointer1],hl
		mov	hl,counter1
		dec	(hl)
		jp	nz,doballloop

		ret


; Note the coding in these plot routines.  They do not use any memory variables,
; and are flexible in terms of the length of the shape they can plot.  They
; are still only useful for 8-bit-high shapes, but heck, with page flipping,
; you can take your time and stack your 8-bit-high shapes as high as you must
; to achieve the necessary effect!

; call with a=x, b=y, hl=shape
plotshape:
		mov	e,a
		mov	a,b
		rrc
		rrc
		rrc
		and	7
		add	237
		mov	d,a
		mov	a,b
		and	7
		mov	b,a
		mov	c,(hl)		; x-size of shape
plotloop1:
		inc	hl
		push	hl
		mov	l,(hl)
		mov	h,0
		mov	a,b		; rotation value
		or	a
		jp	z,plotnorot
plotloop2:
		add	hl,hl
		dec	a
		jp	nz,plotloop2
plotnorot:
		mov	a,(de)
		or	l
		mov	(de),a
		inc	d
		mov	a,(de)
		or	h
		mov	(de),a
		dec	d
		inc	e
		pop	hl
		dec	c
		jp	nz,plotloop1

		ret

; call with a=x, b=y, hl=shape
eraseshape:
		mov	e,a
		mov	a,b
		rrc
		rrc
		rrc
		and	7
		add	237
		mov	d,a
		mov	a,b
		and	7
		mov	b,a
		mov	c,(hl)		; x-size of shape
eraseloop1:
		inc	hl
		push	hl
		mov	a,(hl)
		cpl
		mov	l,a
		mov	h,255
		mov	a,b		; rotation value
		or	a
		jp	z,erasenorot
eraseloop2:
		add	hl,hl
		inc	l		; keep adding low bit 1
		dec	a
		jp	nz,eraseloop2
erasenorot:
		mov	a,(de)
		and	l
		mov	(de),a
		inc	d
		mov	a,(de)
		and	h
		mov	(de),a
		dec	d
		inc	e
		pop	hl
		dec	c
		jp	nz,eraseloop1

		ret

RND:
rnd:
		PUSH	HL
		ADC	(HL)
		LD	HL,RR
		ADC	(HL)
		LD	(HL),A
		INC	HL
		ADD	(HL)
		LD	(HL),A
		INC	HL
		ADC	(HL)
		LD	(HL),A
		POP	HL
		RET

RR		db	1,2,3


; solid small ball
shape_ball:
		db	4
		db	6,15,15,6

; hollow ball
shape_ballh:	db	4
		db	6,9,9,6

shape_box:
		db	10
		db	255,129,129,129,129
		db	129,129,129,129,255

shape_bigball:
		db	8
		db	60,66,129,129,129,129,66,60

xlimitlist:
		db	235,235,231,231

ylimitlist:
		db	61,61,57,57

shapelist:
		dw	shape_ball
		dw	shape_ballh
		dw	shape_box
		dw	shape_bigball

pointer1	ds	2
counter1	ds	1

dataarea	ds	0

; DO NOT PUT ANYTHING AFTER DATAAREA!!!'
