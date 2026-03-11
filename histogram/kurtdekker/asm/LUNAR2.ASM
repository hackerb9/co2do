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

OLD DO NOT USE!

; Author:	Kurt W. Dekker
; Started:	01/03/86 (in Hawaii)
; Updated:	11/10/90
;		08/08/91
;
; Description:	Lunar Lander for TRS-80 Model 100 portable computer
;
; LUNAR W/GROUND V3.0
;
; Another benefit of this being assembled on the new A85.EXE assembler is that
; we can assemble game code right up to the hires screen base at 60672!!  Nice.
;
; Added:
;	High precision speed indicators (for landing)
;	Overall low precision speed indicator (for crude navigation)
;	Real planet names (see "planets")
;	More powerful thrusting (J = 1, K = 2, L = 4)
;	Better display system for perfect landing tics
;	You may "convert" perfects into 99 units of fuel, by pressing
;		shift, ctrl, grph, code, space, tab, or enter.
;
; 11/09/90:
;	Real Planet names are recycled after 16.  Otherwise we run out!
;	Scored 181,580 points in a 2-hour game!
;
; 08/04/91:
;	Added Bolo-style radio beacon for each landing pad.  This is not much
;	use to me, the seasoned player, but a new player would find it useful,
;	especially if they didn't pick the bases up in order.
;
; 08/09/91:
;	Put up a warning blinking spot in the middle of your ship when the
;	fuel level gets too low, just to help you in judging when to convert
;	perfects into fuel.  The warning level for the fuel is equal to 20
;	units plus two times the current gravity, so the warning comes earlier
;	during later waves.

ldir	=	27611
npad	=	6		; number of pads per wave
bfrq	=	2

	org	55500

zzy	call	greet
	call	onetim

	call	init

main	call	cls1
	call	keyin
	call	you
	call	ground
	call	disp
	call	62750
	ld	a,(welc)
	or	a
	call	z,hello
	call	check
	ld	a,(collis)
	or	a
	jp	z,main

	call	expl
	ld	hl,(crashes)
	inc	hl
	ld	(crashes),hl
	ld	b,25		; lose 1/10th of a tank for crashing
	ld	hl,fuel
	inc	(hl)
fdl	dec	(hl)
	jp	z,gamov
	dec	b
	jp	nz,fdl
	ld	hl,(yy)
	ld	de,65436	; move you UP 100 pixels
	add	hl,de
	ld	(yy),hl
	ld	hl,0
	ld	(xmove),hl
	ld	(ymove),hl
	ld	a,4
	ld	(dir),a
	ld	a,(fuel)
	or	a
	jp	nz,main

; game is over! (gameover)
gamov:
	call	finalmsg
wait	call	29250
	cp	13
	jp	nz,wait
	jp	zzy


; final mission message
finalmsg:
	ld	a,12
	rst	32
	ld	hl,em1
	call	10161
	call	crlf

	ld	hl,emscore
	call	10161
	ld	hl,(score)
	call	14804
	ld	a,48
	rst	32
	call	crlf

	ld	hl,emperf
	call	10161
	ld	a,(ttlperf)
	ld	l,a
	ld	h,0
	call	14804
	call	crlf

	ld	hl,emunused
	call	10161
	ld	a,(perf)
	ld	l,a
	ld	h,0
	call	14804
	call	crlf

	ld	hl,emplan
	call	10161
	ld	a,(wave)
	call	findplanet
	call	10161
	call	crlf

	ld	hl,emcompl
	call	10161
	ld	a,(wave)
	ld	l,a
	ld	h,0
	call	14804
	call	crlf

	ld	hl,emcrash
	call	10161
	ld	hl,(crashes)
	call	14804
	call	crlf

	ret


; writes a carriage return/line feed out
crlf:
	push	af
	ld	a,13
	rst	32
	ld	a,10
	rst	32
	pop	af
	ret


; explodes your ship into little smithereens
expl	ld	a,30		; how many frames of explosions
	ld	(ptr1),a
ex1	ld	a,30		; how many streamers per explosion frame
	ld	(ptr2),a
ex2	call	rnd
	and	8
	add	116
	ld	(xp),a
	call	rnd
	and	8
	add	20
	ld	(yp),a
gen3	call	rnd
	and	7
	sub	3
	jp	z,gen3
	ld	(lx),a
gen4	call	rnd
	and	7
	sub	3
	jp	z,gen4
	ld	(ly),a
	ld	c,8		; how long a streamer to draw
plotlp	call	rnd
	and	1
	call	z,click
	call	xpset		; xor pset
	ld	hl,lx
	ld	de,xp
	ld	a,(de)
	add	(hl)
	ld	(de),a
	inc	hl
	inc	de
	ld	a,(de)
	add	(hl)
	ld	(de),a
	cp	64
	jp	nc,oute
	dec	c
	jp	nz,plotlp
oute	ld	hl,ptr2
	dec	(hl)
	jp	nz,ex2
	call	62750
	ld	hl,ptr1
	dec	(hl)
	jp	nz,ex1
	ret

play	ld	a,(hl)
	or	a
	jp	z,quit
	ld	b,a
	inc	hl
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	inc	hl
	call	son
son1	ld	de,1000
son2	dec	de
	ld	a,d
	or	e
	jp	nz,son2
	dec	b
	jp	nz,son1
	xor	a
	out	186
	ld	de,500
poz	dec	de
	ld	a,d
	or	e
	jp	nz,poz
	push	hl
	call	keyin
	pop	hl
	jp	play
quit	ld	a,239
	out	186
	ret
son	di
	ld	a,(snd)
	or	a
	ret	z
	ld	a,e
	out	188
	ld	a,d
	or	64
	out	189
	ld	a,195
	out	184
	in	186
	and	248
	or	32
	out	186
	ret

ground	ld	hl,(xx)
	ld	a,l
	and	7
	ld	b,a
	ld	a,65
	sub	b
	ld	(xp),a
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	a,h
	sub	9
	ld	(ptr2),a
	ld	e,a
	ld	d,0
	ld	hl,gnd
	add	hl,de
	ld	a,(hl)
	ld	(prev),a
	inc	hl
	ld	(hold),hl
	ld	a,15
	ld	(ptr1),a

glp1	ld	a,(prev)
	ld	hl,(hold)
	ld	b,(hl)
	sub	b
	inc	hl
	ld	(hold),hl
	ld	(mv),a
	ld	a,(prev)
	ld	l,a
	ld	a,b
	ld	(prev),a
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ex	de,hl
	ld	hl,(yy)
	ld	a,e
	sub	l
	ld	l,a
	ld	a,d
	sbc	h
	ld	h,a
	ld	(holdy),hl
	ld	c,8
	ld	a,(mv)
	cp	128
	jp	c,noneg
	cpl
	inc	a
noneg	ld	(cnt),a
glp2	xor	a
	ld	(onsc),a
	ld	hl,(holdy)
	ld	de,32
	add	hl,de
	ld	a,h
	or	a
	jp	nz,nopset
	ld	de,65504
	add	hl,de
	ld	a,l
	ld	(yp),a
	ld	a,(xp)
	cp	65
	jp	c,nopset
	cp	175
	jp	nc,nopset
	ld	a,(yp)
	cp	64
	jp	nc,npset1
	call	pset
	ld	(onsc),a
npset1	ld	a,(cnt)
	cp	2
	jp	c,nopset
	dec	a
	ld	b,a
pslp	ld	hl,yp
	dec	(hl)
	ld	a,(mv)
	and	128
	jp	z,decit
	inc	(hl)
	inc	(hl)
decit	ld	a,(yp)
	cp	64
	call	c,pset
	dec	b
	jp	nz,pslp
nopset	ld	hl,xp
	inc	(hl)
	ld	a,(mv)
	cpl
	inc	a
	ld	e,a
	ld	d,255
	and	128
	jp	nz,leave
	ld	d,0
leave	ld	hl,(holdy)
	add	hl,de
	ld	(holdy),hl
	dec	c
	jp	nz,glp2

	ld	a,(onsc)
	or	a
	jp	z,nopads
	ld	hl,(holdy)
	ld	a,h
	or	a
	jp	nz,nopads
	ld	hl,padf
	ld	(holdit),hl
	ld	b,0
pdlp	ld	hl,(holdit)
	ld	a,(hl)
	inc	hl
	ld	(holdit),hl
	or	a
	jp	z,nexp
	ld	a,b
	add	a
	add	a
	add	a
	add	a
	add	a
	add	48
	ld	l,a
	ld	a,(ptr2)
	cp	l
	jp	nz,nexp
	ld	hl,yp
	dec	(hl)
	ld	a,(hl)
	cp	62
	jp	nc,nexp
	ld	a,(xp)
	push	af
	push	bc
	sub	7
	ld	(xp),a
	cp	65
	jp	c,nobll
	cp	175
	jp	nc,nobll
	ld	a,(yet)
	and	bfrq
	call	z,pset
nobll	ld	hl,yp
	inc	(hl)
	inc	(hl)
	dec	hl
	inc	(hl)
	ld	b,6
pdpslp:				; loop and draw dots for a landing pad
	ld	a,(xp)
	cp	65		; left edge of center portion of screen
	jp	c,nopdps
	cp	175		; right edge of center portion of screen
	jp	nc,nopdps
	call	pset
nopdps:
	ld	hl,xp
	inc	(hl)
	inc	(hl)
	dec	b
	jp	nz,pdpslp
	dec	(hl)
	ld	a,(hl)
	inc	hl
	dec	(hl)
	dec	(hl)
	cp	65
	jp	c,noblr
	cp	175
	jp	nc,noblr
	ld	a,(yet)
	and	bfrq
	call	nz,pset
noblr	pop	bc
	pop	af
	ld	(xp),a
nexp	inc	b
	ld	a,b
	cp	npad
	jp	nz,pdlp

nopads:
	ld	hl,ptr2
	inc	(hl)
	ld	hl,ptr1
	dec	(hl)
	jp	nz,glp1
	ret

you:
; first check if convert key has been pressed
	ld	a,(key8)
	and	135
	jp	nz,docvt
	ld	a,(key9)
	and	15
	jp	z,nocvt1
docvt:
	ld	a,(prevcvt)
	or	a
	jp	nz,donecvt	; still being held down!
	ld	a,1
	ld	(prevcvt),a	; now it IS held down
	ld	hl,perf
	ld	a,(hl)
	or	a
	jp	z,donecvt	; you don't HAVE perfects to convert!
	dec	(hl)
	ld	hl,fuel
	ld	a,99
	add	(hl)
	jp	nc,notankfull
	ld	a,255
notankfull:
	ld	(hl),a
	jp	donecvt
nocvt1:
	xor	a
	ld	(prevcvt),a
donecvt:
; now get on with normal YOU functions
	call	move
	call	dampen
	xor	a
	ld	(fahr),a
	ld	a,(xhi)		; check if you're against the left edge
	or	a
	jp	nz,nospc1
	ld	hl,0
	ld	(xmove),hl
	ld	a,7
	ld	(dir),a
	ld	a,1
	ld	(fahr),a
	jp	norotr
nospc1:
	cp	7		; check if you're against the right edge
	jp	nz,nospc2
	ld	hl,0
	ld	(xmove),hl
	ld	a,1
	ld	(dir),a
	ld	a,1
	ld	(fahr),a
	jp	norotr
nospc2:
	ld	a,(fuel)
	or	a
	jp	z,norotr	; can't rotate when there's no fuel!
				; (even though rotation takes no fuel to do)
	ld	a,(key1)
	and	1		; Press the 'A' key to rotate left
	jp	z,norotl
	ld	hl,dir
	ld	a,(hl)
	dec	a
	and	15
	ld	(hl),a
	jp	norotr
norotl:
	ld	a,(key1)
	and	2		; Press the 'S' key to rotate right
	jp	z,norotr
	ld	hl,dir
	ld	a,(hl)
	inc	a
	and	15
	ld	(hl),a
norotr:
	ld	a,(fahr)
	or	a
	jp	nz,dofahr
	ld	a,(key1)
	and	64
	call	nz,blast	; single-thrust
	ld	a,(key1)
	and	128
	jp	z,noblast2
	call	blast		; double-thrust
	call	blast
noblast2:
	ld	a,(key2)
	and	128
	jp	z,noblast4	; this is hyper-blast!
	call	blast
	call	blast
	call	blast
	call	blast
noblast4:
	ret

; fires your thrusters, adds the movements. detracts from fuel, etc.
blast:
	ld	a,1
	ld	(fahr),a
dofahr:
	ld	hl,fuel
	ld	a,(hl)
	or	a
	ret	z
	push	hl
	ld	hl,fool
	dec	(hl)
	ld	a,(hl)
	pop	hl
	and	1
	jp	nz,dothr
	dec	(hl)
dothr:
	call	thrust
	call	push
	ret

dampen:	ld	hl,(xmove)
	call	damphl
	ld	(xmove),hl
	ld	hl,(ymove)
	call	damphl
	ld	(ymove),hl
	ret

damphl	ld	a,h
	or	l
	ret	z
	ld	a,h
	and	128
	jp	z,decdamp
	inc	hl
	ret
decdamp	dec	hl
	ret

phl	ld	bc,pout
	push	bc
	call	14808
	ret

pout	inc	hl
	ld	a,(hl)
	or	a
	ret	z
	sub	48
	call	pch
	jp	pout

pch	push	hl
	ld	b,a
	add	a
	add	a
	add	b
	ld	e,a
	ld	d,0
	ld	hl,30561
	add	hl,de
	ex	de,hl
	ld	hl,(curs)
	ld	b,5
pchl	ld	a,(de)
	ld	(hl),a
	inc	l
	inc	de
	dec	b
	jp	nz,pchl
	ld	(hl),0
	inc	l
	ld	(curs),hl
	pop	hl
	ret

vitals:
	ld	hl,60850
	ld	(curs),hl
	ld	hl,(score)
	call	phl
	xor	a
	call	pch
	ld	hl,61104
	ld	a,(fuel)
	rrc
	rrc
	and	63
	inc	a
	ld	b,a
fulp	ld	(hl),255
	inc	l
	dec	b
	jp	nz,fulp
fulp1	ld	a,l
	cp	240
	jp	z,putspeed	; writes the speed indicators
	ld	(hl),0
	inc	l
	jp	fulp1
putspeed:			; writes the horiz and vert speed indicators
; write box out at right side of screen
	ld	l,176
	ld	b,17
	xor	a
ps001	ld	h,242
	ld	(hl),32		; top edge of speed box
	ld	h,243
	ld	(hl),a
	ld	h,244
	ld	(hl),128	; bottom edge of speed box
	xor	64		; center dotted line (horiz)
	inc	l
	dec	b
	jp	nz,ps001

	ld	h,242		; right edge of box
	ld	(hl),224
	ld	h,243
	ld	(hl),255
	ld	h,244
	ld	(hl),255

	ld	l,184		; center dotted line (vertical)
	ld	h,242
	ld	(hl),160
	ld	h,243
	ld	(hl),170
	ld	h,244
	ld	(hl),170

	ld	hl,(xmove)
	ld	de,2176		; makes movements positive (2048 + 128)
	add	hl,de
	ld	a,h
	add	175		; right edge of speed box
	ld	(xp),a
	ld	hl,(ymove)
	add	hl,de
	ld	a,h
	add	46		; top edge of speed box
	ld	(yp),a
	call	pset		; left side dot
	ld	hl,xp
	inc	(hl)
	call	pset		; center dot
	ld	hl,xp
	inc	(hl)
	call	pset		; right dot
	ld	hl,xp
	dec	(hl)
	inc	hl		; point to yp
	dec	(hl)
	call	pset		; top dot
	ld	hl,yp
	inc	(hl)
	inc	(hl)
	call	pset		; bottom dot

; puts on the high-resolution HORIZONTAL speed indicator (for landing)
	ld	hl,(xmove)
	ex	de,hl
	ld	a,d
	cmp	255
	jp	z,hrxleft
	cmp	0
	jp	z,hrxright
	and	128
	jp	nz,hrxmaxl
hrxmaxr:
	ld	l,174		; extreme right
	jp	finhrx
hrxmaxl:
	ld	l,65		; extreme left
	jp	finhrx
hrxright:
	ld	a,e
	cp	220
	jp	nc,hrxmaxr
	rrc
	rrc
	and	63
	add	120
	ld	l,a
	jp	finhrx
hrxleft:
	ld	a,e
	cp	36
	jp	c,hrxmaxl
	sub	36
	rrc
	rrc
	and	63
	add	65
	ld	l,a
;	jp	finhrx
finhrx:
	ld	h,244
	ld	a,(hl)
	or	96		; horiz hires speed "tick" (at bottom)
	ld	(hl),a
	ld	h,237
	ld	a,(hl)
	or	6		; horiz hires speed "tick" (at top)
	ld	(hl),a
	ld	l,120		; center
	ld	a,(hl)
	or	1		; speed zero on horizontal
	ld	(hl),a
	ld	h,244
	ld	a,(hl)
	or	128
	ld	(hl),a

; put on the BOLO-style homing beacon indicator (for finding landing pads)
	ld	b,0
	ld	c,0
	ld	hl,padf
	ld	(beaconhl),hl
beaconlp:
	ld	hl,(beaconhl)
	ld	a,(hl)
	or	a
	jp	z,no_pad_here
	ld	a,b
	add	a
	add	a
	add	a
	add	a
	add	a
	add	48
	ld	hl,(xx)
	ld	de,65512		; (-24)
	add	hl,de
	ld	e,a
	ld	d,0
	ex	de,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	rst	24
	jp	c,pad_to_right
	ld	a,c
	or	2
	ld	c,a
	jp	no_pad_here
pad_to_right:
	ld	a,c
	or	1
	ld	c,a
no_pad_here:
	ld	hl,(beaconhl)
	inc	hl
	ld	(beaconhl),hl
	inc	b
	ld	a,b
	cmp	npad
	jp	nz,beaconlp

	ld	h,242
	ld	l,210
	ld	(hl),255		; leftmost edge of beacon
	inc	l
	ld	b,8
	ld	d,129			; no beacon
	ld	a,c
	and	1
	jp	z,no_beacon1
	ld	d,255
no_beacon1:
	ld	(hl),d
	inc	l
	dec	b
	ld	a,b
	or	a
	jp	nz,no_beacon1

	ld	(hl),255
	inc	l
	inc	l
	ld	(hl),255		; center of beacon
	inc	l

	ld	b,8
	ld	d,129			; no beacon
	ld	a,c
	and	2
	jp	z,no_beacon2
	ld	d,255
no_beacon2:
	ld	(hl),d
	inc	l
	dec	b
	ld	a,b
	or	a
	jp	nz,no_beacon2

	ld	(hl),255		; rightmost edge of beacon

; puts on the high-resolution VERTICAL speed indicator (for landing)
	ld	hl,(ymove)
	ld	a,h
	and	128
	jp	z,notnegspeed
				; deal with negative speed here
	ld	a,0
	ld	(yp),a
	jmp	tickmark
notnegspeed:
	ld	a,h
	or	a
	jp	nz,toofastspeed
	ld	a,l
	rrc
	rrc
	and	63
	ld	(yp),a
tickmark:
	ld	a,65
	ld	(xp),a
	call	pset
	ld	hl,xp
	inc	(hl)
	call	pset
	ld	hl,xp
	inc	(hl)
	call	pset
	ld	hl,xp
	ld	(hl),172
	call	pset
	ld	hl,xp
	inc	(hl)
	call	pset
	ld	hl,xp
	inc	(hl)
	call	pset
	ret
toofastspeed:			; deal with high positive speeds here
	ld	a,63
	ld	(yp),a
	jmp	tickmark

disp	call	center
	call	rocket
entry	call	vitals

; puts the perfect tick marks on the screen
	ld	hl,61361
	ld	a,(perf)
	or	a
	jp	z,noprf
retry5s:
	cp	5
	jp	c,noprf5s
	ld	(hl),84		; asterisk (for 5 perfects)
	inc	l
	ld	(hl),40
	inc	l
	ld	(hl),254
	inc	l
	ld	(hl),40
	inc	l
	ld	(hl),84
	inc	l
	ld	(hl),0
	inc	l
	sub	5
	jp	z,noprf
	jmp	retry5s
noprf5s:
prflp	ld	(hl),248
	inc	l
	ld	(hl),24
	inc	l
	ld	(hl),0
	inc	l
	dec	a
	jp	nz,prflp
noprf:
	ld	b,16
	xor	a
whitelp:			; white out area to the right of the perfects
	ld	(hl),a		; so that changing from 4 to 5 won't leave
	inc	l		; extra 1 digit flags or parts thereof
	dec	b
	jp	nz,whitelp

; proceeds to redraw the left "big" picture of the planet
	xor	a
	ld	(xp),a
	ld	hl,hold64
dlp1	ld	a,(hl)
	ld	(yp),a
	push	hl
	call	pset
	ld	hl,xp
	inc	(hl)
	ld	a,(hl)
	pop	hl
	inc	hl
	cp	64
	jp	nz,dlp1
	ld	hl,(oldx)
	ld	(xp),hl
	call	preset
	ld	hl,(xx)
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	a,h
	ld	(xp),a
	ld	hl,(yy)
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	a,h
	ld	(yp),a
	ld	hl,yet
	dec	(hl)
	ld	a,(hl)
	and	2
	call	z,pset
	ld	hl,(xp)
	ld	(oldx),hl
	ret

click:
	ld	a,(snd)
	or	a
	ret	z
	jp	30326

center:
	ld	a,(grav)		; formula for low-fuel warning
	add	a
	add	30
	ld	c,a
	ld	a,(fuel)
	or	a
	jp	z,for_sure_solid	; solid when no fuel
	cmp	c			; warning level for fuel
	jp	nc,not_fuel_blink
	ld	hl,blinkfuel
	inc	(hl)
	ld	a,(hl)
	and	1
	jp	z,not_fuel_blink
for_sure_solid:
	ld	c,0
	ld	hl,61296
	ld	de,topcir1
	ld	b,16
	call	doctr
	ld	hl,61552
	ld	de,botcir1
	ld	b,16
	call	doctr
	jmp	common_collis
not_fuel_blink:
	ld	c,0
	ld	hl,61296
	ld	de,topcir
	ld	b,16
	call	doctr
	ld	hl,61552
	ld	de,botcir
	ld	b,16
	call	doctr
common_collis:
	ld	hl,collis
	ld	a,(hl)
	or	c
	ld	(hl),a
	ret

doctr	ld	a,(de)
	and	(hl)
	or	c
	ld	c,a
	ld	a,(de)
	or	(hl)
	ld	(hl),a
	inc	l
	inc	de
	dec	b
	jp	nz,doctr
	ret

; looks up movement, x and y, based on direction
push:
	ld	a,(dir)
	add	a
	ld	e,a
	ld	d,0
	push	de
	ld	hl,xpush
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,(xmove)
	add	hl,de
; test for maximum x movement (cannot be more than 8 or -8 in high byte)
	ld	a,h
	cmp	8	; maximum x movement?
	jp	nz,nolimx1
	ld	h,7
	jmp	nolimitx
nolimx1:
	cmp	248
	jp	nz,nolimitx
	ld	h,249
nolimitx:
	ld	(xmove),hl
	pop	de
	ld	hl,ypush
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	ld	hl,(ymove)
	add	hl,de
; test for maximum y movement (cannot be more than 8 or -8 in high byte)
	ld	a,h
	cmp	8	; maximum y movement?
	jp	nz,nolimy1
	ld	h,7
	jmp	nolimity
nolimy1:
	cmp	248
	jp	nz,nolimity
	ld	h,249
nolimity:
	ld	(ymove),hl
	ret

move:
	ld	hl,(ymove)
	ld	a,(grav)		; add gravity to ymove
	ld	e,a
	ld	d,0
	add	hl,de
	ld	(ymove),hl

	ld	hl,(xmove)
	ld	a,h
	ex	de,hl
	ld	hl,(xpos)
	add	hl,de
	ld	(xpos),hl
	ld	hl,xhi
	push	af
	and	128
	jp	z,plusx
	pop	af
	jp	c,no1
	dec	(hl)
	ld	a,(hl)
	and	7
	ld	(hl),a
	jp	no1
plusx	pop	af
	jp	nc,no1
	inc	(hl)
	ld	a,(hl)
	and	7
	ld	(hl),a

no1	ld	hl,(ymove)
	ld	a,h
	ex	de,hl
	ld	hl,(ypos)
	add	hl,de
	ld	(ypos),hl
	ld	hl,yhi
	push	af
	and	128
	jp	z,plusy		; you are moving downwards
	pop	af
	jp	c,no2
	dec	(hl)
	ld	a,(hl)
	and	7
	ld	(hl),a
	cp	7
	call	z,inject	; reinject if you go off top of screen
	jp	no2
plusy	pop	af
	jp	nc,no2
	inc	(hl)
	ld	a,(hl)
	and	7
	ld	(hl),a

no2	ret

thrust	ld	a,(dir)
	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	de,t1
	add	hl,de
	push	hl
	ld	a,(dir)
	add	a
	ld	e,a
	ld	d,0
	ld	hl,tlocs
	add	hl,de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	pop	de
	call	rslam
	ret
rocket	ld	a,(dir)
	ld	l,a
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ld	de,r1
	add	hl,de
	push	hl
	ld	a,(dir)
	add	a
	ld	e,a
	ld	d,0
	ld	hl,locats
	add	hl,de
	ld	a,(hl)
	inc	hl
	ld	h,(hl)
	ld	l,a
	pop	de
	call	slam
	ret

keyin:
	di
	ld	a,253
	out	177
	in	178
	or	1
	out	178
	in	225
	cpl
	ld	(key1),a	; asdfghjk keys
	ld	a,254
	out	177
	in	225
	cpl
	ld	(key2),a	; zxcvbnml keys
	ld	a,191
	out	177
	in	225
	cpl
	ld	(key8),a	; space, enter, etc.
pauz	ld	a,255
	out	177
	in	178
	and	254
	out	178
	in	225
	and	16
	jp	z,pauz
	in	225
	cpl
	ld	(key9),a
	and	32
	ld	(snd),a
	ret

pset	call	calc
	or	(hl)
	ld	(hl),a
	ret

xpset	call	calc
	xor	(hl)
	ld	(hl),a
	ret

preset	call	calc
	cpl
	and	(hl)
	ld	(hl),a
	ret

calc	ld	a,(yp)
	rrc
	rrc
	rrc
	and	7
	add	237
	ld	h,a
	ld	a,(xp)
	ld	l,a
	push	hl
	ld	a,(yp)
	and	7
	ld	e,a
	ld	d,0
	ld	hl,bits
	add	hl,de
	ld	a,(hl)
	pop	hl
	ret

; 10/14/90 finally added a greeting screen
greet	ld	hl,m_greet
	call	10161
greetlp	call	rnd
	call	29250
	cp	13
	jp	nz,greetlp
	ret

onetim:	ld	a,12
	rst	32
	xor	a
	ld	(perf),a
	ld	(ttlperf),a
	ld	(wave),a
	ld	hl,0
	ld	(score),hl
	ld	(crashes),hl
	ld	a,6
	ld	(grav),a
	ret

; initialize the ground for a new wave
makgnd:
	ld	a,255
	ld	(fuel),a		; full tank of gas
	xor	a
	ld	(welc),a		; cause the welcome to occur
	ld	a,npad
	ld	(numpad),a
	ld	hl,padf
sfhi	ld	(hl),1
	inc	hl
	dec	b
	jp	nz,sfhi

	ld	hl,gnd
	ld	b,128
	ld	c,64
dnlp	call	rnd
	and	128
	jp	z,nor1
gen1	call	rnd
	and	7
	sub	2
	jp	z,gen1
	add	c
	ld	c,a
nor1	ld	(hl),c
	ld	a,c
	cp	250
	jp	c,otay1
	ld	c,249
otay1	inc	hl
	dec	b
	jp	nz,dnlp

	ld	b,128
uplp	call	rnd
	and	128
	jp	z,nor2
gen2	call	rnd
	and	7
	sub	5
	jp	z,gen2
	add	c
	ld	c,a
nor2	ld	(hl),c
	ld	a,c
	cp	20
	jp	nc,otay2
	ld	c,21
otay2	inc	hl
	dec	b
	jp	nz,uplp

; This initializes the positions of the landing pads
	ld	b,0
putpads	ld	a,b
	add	a
	add	a
	add	a
	add	a
	add	a
	add	48
	ld	e,a
	ld	d,0
	ld	hl,gnd
	add	hl,de
	ld	a,(hl)		; make a flat spot for the landing pad
	inc	hl
	ld	(hl),a
	inc	hl
	ld	(hl),a
	push	af
	ld	a,b
	ld	e,a
	ld	d,0
	ld	hl,pady
	add	hl,de
	pop	af
	ld	(hl),a
	inc	b
	ld	a,b
	cp	npad
	jp	nz,putpads

	call	inject

	ld	a,64
	ld	(ptr1),a
	ld	hl,hold64
	ld	de,gnd
avglp	push	hl
	ld	b,4
	ld	c,0
avglp1	ld	a,(de)
	rrc
	rrc
	and	63
	add	c
	ld	c,a
	inc	de
	dec	b
	jp	nz,avglp1
	pop	hl
	ld	a,c
	rrc
	rrc
	and	63
	ld	(hl),a
	inc	hl
	push	hl
	ld	hl,ptr1
	dec	(hl)
	pop	hl
	jp	nz,avglp
	call	cls
	ret


; injects your ship from outer space (reentry)
inject:
	call	rnd
	and	15
	ld	(dir),a			; randomize your reentry orientation
	ld	hl,0
	ld	(ymove),hl
	ld	(xpos),hl
	ld	hl,40
	ld	(ypos),hl
	ld	a,4
	ld	(xhi),a
	ld	a,0
	ld	(yhi),a
	call	rnd
	and	1
	jp	z,injectr		; shoot in going right.
	ld	hl,63744		; - (7 * 256)
	ld	(xmove),hl
	ret
injectr:
	ld	hl,1792			; (7 * 256)
	ld	(xmove),hl
	ret


tellstats:
	call	keyin			; so that sound may be on or off
	mov	a,12			; cls
	rst	32

	ld	hl,newwmsg
	call	10161

	ld	hl,miplan		; Planet:
	call	10161
	ld	a,(wave)
	call	findplanet
	call	10161			; prints which planet (by name)

	call	crlf

	ld	hl,migrav		; Gravity:
	call	10161
	ld	a,(grav)
	ld	l,a
	ld	h,0
	call	14804			; print gravity
	call	crlf

	ld	hl,miobject		; # of objectives
	call	10161
	ld	hl,6			; constant
	call	14804
	call	crlf

	ld	hl,miscore		; Current Score
	call	10161
	ld	hl,(score)
	call	14804
	ld	a,48
	rst	32			; trailing zero
	call	crlf

	ld	hl,miperf		; Perfects:
	call	10161
	ld	a,(perf)
	ld	l,a
	ld	h,0
	call	14804
	call	crlf

	ld	hl,play1		; too tee, teedle do tee!
	call	play
	ld	hl,miready
	call	10161
	ld	hl,play1
	call	play

	ret


; pass planet number (1 -> x) in a, and this will return the address of
; the ascii planet name.
findplanet:
	dec	a
	and	15			; recycle planets over again!
	ld	l,a
	ld	h,0
	add	hl,hl
	ld	de,planets
	add	hl,de
	ld	e,(hl)
	inc	hl
	ld	d,(hl)
	push	de
	pop	hl
	ret

hello:
	ld	a,1
	ld	(welc),a
	ld	a,25
	ld	(ptr1),a
dt1	ld	b,30
	ld	c,70
	call	beep
	ld	a,(ptr1)
	ld	b,a
dt2	ld	hl,1500
dt3	dec	hl
	ld	a,l
	or	h
	jp	nz,dt3
	dec	b
	jp	nz,dt2
	call	keyin
	ld	hl,ptr1
	dec	(hl)
	jp	nz,dt1
	ret

cls	ld	hl,60672
	ld	de,60673
	ld	bc,2047
	ld	(hl),0
	jp	ldir

; clears the central (magnified) portion of the screen
cls1	xor	a
	ld	(collis),a
	ld	h,237
clp1	ld	l,64
	ld	(hl),255	; left border
	inc	l
	ld	b,110
	xor	a
clp2	ld	(hl),a
	inc	l
	dec	b
	jp	nz,clp2
	ld	(hl),255	; right border
	inc	h
	ld	a,h
	cp	245
	jp	nz,clp1
	ret

rnd	push	hl
	adc	(hl)
	ld	hl,rr
	adc	(hl)
	ld	(hl),a
	inc	hl
	adc	(hl)
	ld	(hl),a
	inc	hl
	sbc	(hl)
	ld	(hl),a
	adc	b
	pop	hl
	ret

slam	ld	c,0
	ld	b,8
sllp1	ld	a,(de)
	and	(hl)
	or	c
	ld	c,a
	ld	a,(de)
	or	(hl)
	ld	(hl),a
	inc	de
	inc	l
	dec	b
	jp	nz,sllp1
	push	bc
	ld	bc,248
	add	hl,bc
	pop	bc
	ld	b,8
sllp2	ld	a,(de)
	and	(hl)
	or	c
	ld	c,a
	ld	a,(de)
	or	(hl)
	ld	(hl),a
	inc	de
	inc	l
	dec	b
	jp	nz,sllp2
	ld	hl,collis
	ld	a,(hl)
	or	c
	ld	(hl),a
	ret

rslam	ld	b,16
rsllp1	call	rnd
	ex	de,hl
	and	(hl)
	ex	de,hl
	or	(hl)
	ld	(hl),a
	inc	de
	inc	l
	dec	b
	jp	nz,rsllp1
	ld	bc,240
	add	hl,bc
	ld	b,16
rsllp2	call	rnd
	ex	de,hl
	and	(hl)
	ex	de,hl
	or	(hl)
	ld	(hl),a
	inc	de
	inc	l
	dec	b
	jp	nz,rsllp2
	ret

check	ld	a,(xhi)
	dec	a
	cp	6
	ret	nc
	ld	e,a
	ld	d,0
	ld	hl,padf
	add	hl,de
	ld	a,(hl)
	or	a
	ret	z
	ld	a,(xx)
	cp	151
	ret	c
	cp	155
	ret	nc
	ld	a,(dir)
	cp	4
	ret	nz
	ld	hl,pady
	add	hl,de
	ld	l,(hl)
	ld	h,0
	add	hl,hl
	add	hl,hl
	add	hl,hl
	ex	de,hl
	ld	hl,(yy)
	ld	bc,35
	add	hl,bc
	rst	24
	ret	nz
	ld	a,(ymvh)
	or	a
	ret	nz
	call	bonus
	ld	a,(xhi)
	dec	a
	ld	e,a
	ld	d,0
	ld	hl,padf
	add	hl,de
	ld	(hl),0
	ld	hl,0
	ld	(xmove),hl
	xor	a
	ld	(xpos),a
	ld	(ypos),a
	ld	hl,yy
	dec	(hl)
	ld	hl,65024
	ld	(ymove),hl
	ld	hl,numpad
	dec	(hl)
	ret	nz
; at this point, all the pads have been landed on, the wave is over!
	ld	de,100			; 1000-point bonus for wave done
	ld	hl,(score)
	add	hl,de
	ld	a,(perf)
	or	a
	jp	z,noprb
	ld	de,20		; 200 points for each perfect landing
	ld	b,a
prblp	add	hl,de
	dec	b
	jp	nz,prblp
noprb	ld	(score),hl
	call	vitals
vg1	ld	hl,fuel
	ld	a,(hl)
	or	a
	jp	z,endvg
	dec	(hl)
	ld	hl,(score)
	inc	hl		; 10 points for each piece of fuel remaining
	ld	(score),hl
	call	vitals
	ld	b,15
	ld	c,15
	call	beep
	call	62750
	jp	vg1

endvg:
	call	62750
	ld	hl,grav
	inc	(hl)
	inc	(hl)		; increase gravity
init:
	ld	hl,wave
	inc	(hl)
	call	makgnd
	call	tellstats
	ret

bonus	ld	hl,ymove
	ld	a,(hl)
	cp	14
	jp	c,speci
	xor	a
	sub	(hl)
	rrc
	rrc
	and	63
	add	20
	jp	nospeci
speci	ld	a,99
	ld	hl,ttlperf
	inc	(hl)
	ld	hl,perf
	inc	(hl)
nospeci	ld	(ptr1),a
	xor	a
	ld	(ptr2),a
bonlp	ld	hl,62065
	ld	(curs),hl
	ld	b,18
oo	ld	(hl),0
	inc	l
	dec	b
	jp	nz,oo
	ld	a,(ptr1)
	ld	l,a
	ld	h,0
	call	phl
	xor	a
	call	pch
	call	entry	; just do vitals, not rocket and central screen
	call	62750
	ld	a,(ptr2)
	or	a
	jp	nz,nobwit
	ld	hl,play2
	call	play
	ld	a,1
	ld	(ptr2),a
nobwit	ld	b,20
	ld	c,30
	call	beep
	ld	hl,(score)
	inc	hl
	ld	(score),hl
	ld	hl,fuel
	inc	(hl)
	jp	nz,okfu
	dec	(hl)
okfu	ld	hl,ptr1
	dec	(hl)
	ld	a,(hl)
	cp	255
	jp	nz,bonlp
	ld	hl,(score)
	dec	hl
	ld	(score),hl
	ret

beep	ld	a,b
bp1	dec	a
	jp	nz,bp1
	call	click
	dec	c
	jp	nz,beep
	ret

xpush	dw	65503
	dw	65506
	dw	65513
	dw	65524
	dw	0
	dw	12
	dw	23
	dw	30
	dw	33
	dw	30
	dw	23
	dw	12
	dw	0
	dw	65524
	dw	65513
	dw	65506

ypush	dw	0
	dw	65524
	dw	65513
	dw	65506
	dw	65503
	dw	65506
	dw	65513
	dw	65524
	dw	0
	dw	12
	dw	23
	dw	30
	dw	33
	dw	30
	dw	23
	dw	12

plan1	dm	Io (moon)
	db	0
plan2	dm	The Moon
	db	0
plan3	dm	Mercury
	db	0
plan4	dm	Pluto
	db	0
plan5	dm	Mars
	db	0
plan6	dm	Venus
	db	0
plan7	dm	Earth
	db	0
plan8	dm	Neptune
	db	0
plan9	dm	Uranus
	db	0
plan10	dm	Saturn
	db	0
plan11	dm	Jupiter
	db	0
plan12	dm	Altair
	db	0
plan13	dm	Betelgeuse
	db	0
plan14	dm	Capella
	db	0
plan15	dm	Denebola
	db	0
plan16	dm	Eridani
	db	0

planets	dw	plan1,plan2,plan3,plan4,plan5,plan6,plan7,plan8
	dw	plan9,plan10,plan11,plan12,plan13,plan14,plan15,plan16

newwmsg:
	db	32,32,27
	dm	p*** MISSION INFORMATION PRINTOUT ***
	db	27
	dm	q
	db	13,10
	db	0

emplan:
miplan:
	db	9
	dm	Planet:
	db	9,9,0

migrav:
	db	9
	dm	Gravity:
	db	9,0

miobject:
	db	9
	dm	Objectives:
	db	9,0

emscore:
miscore:
	db	9
	dm	Score:
	db	9,9,0

emperf:
miperf:
	db	9
	dm	Perfects:
	db	9,0

emunused:
	db	9
	dm	Unconverted:
	db	9,0

emcompl:
	db	9
	dm	Planet No.
	db	9,0

emcrash:
	db	9
	dm	Crashes:
	db	9,0

miready:
	db	9,9,27
	dm	p READY!!!
	db	32
	db	27
	dm	q
	db	0

m_greet	db	12,10,27
	dm	pLunar Lander
	db	27
	dm	q, V 3.3, Dated 08/09/91
	db	13,10,10
	dm	By Kurt W. Dekker
	db	13,10,10
	dm	Press <Enter> to begin...
	db	0

em1	dfb	32,32,27
	dm	p*** MISSION TERMINATED - SUMMARY ***
	db	27
	dm	q
	db	0

play1	dfb	40		; greeting sounds
	dw	4697
	dfb	75
	dw	3134
	dfb	5
	dw	2348
	dfb	5
	dw	3134
	dfb	5
	dw	3728
	dfb	5
	dw	4697
	dfb	75
	dw	2348
	dfb	40
	dw	0
	dfb	0

play2	dfb	40		; successful landing sounds
	dw	4697
	dfb	20
	dw	4697
	dfb	20
	dw	3728
	dfb	20
	dw	3134
	dfb	20
	dw	3728
	dfb	20
	dw	3134
	dfb	20
	dw	3728
	dfb	40
	dw	4184
	dfb	20
	dw	4184
	dfb	20
	dw	3516
	dfb	80
	dw	2793

	dfb	20
	dw	2484
	dfb	20
	dw	3134
	dfb	20
	dw	3728
	dfb	20
	dw	2484

	dfb	20
	dw	3134
	dfb	20
	dw	3728
	dfb	20
	dw	2484
	dfb	20
	dw	3134

	dfb	40
	dw	2348
	dfb	20
	dw	2484
	dfb	100
	dw	2348
	dfb	0

; your ship's bulbous main body
topcir	dfb	240,28,6,2,3,1,1,1
	dfb	1,1,1,3,2,6,28,240

botcir	dfb	15,56,96,64,192,128,128,128
	dfb	128,128,128,192,64,96,56,15

; your ship's bulbous main body, FILLED IN SOLID!
topcir1	dfb	240,252,254,254,255,255,255,255
	dfb	255,255,255,255,254,254,252,240

botcir1	dfb	15,63,127,127,255,255,255,255
	dfb	255,255,255,255,127,127,63,15

bits	dfb	1,2,4,8,16,32,64,128

; rocket cone shapes
r1	dfb	32,48,16,0,0,0,0,0
	dfb	4,12,8,0,0,0,0,0

	dfb	0,0,64,128,130,2,4,0
	dfb	0,0,0,0,0,0,0,0

	dfb	128,0,0,16,16,48,0,0
	dfb	3,2,0,0,0,0,0,0

	dfb	0,0,0,0,0,0,64,128
	dfb	0,3,4,0,0,0,0,1

	dfb	6,3,0,0,0,0,3,6
	dfb	0,0,0,0,0,0,0,0

	dfb	128,64,0,0,0,0,0,0
	dfb	1,0,0,0,0,4,3,0

	dfb	0,0,48,16,16,0,0,128
	dfb	0,0,0,0,0,0,2,3

	dfb	0,4,2,130,128,64,0,0
	dfb	0,0,0,0,0,0,0,0

	dfb	0,0,0,0,0,16,48,32
	dfb	0,0,0,0,0,8,12,4

	dfb	0,32,64,65,1,2,0,0
	dfb	0,0,0,0,0,0,0,0

	dfb	0,0,0,0,0,0,64,192
	dfb	0,0,12,8,8,0,0,1

	dfb	128,0,0,0,0,32,192,0
	dfb	1,2,0,0,0,0,0,0

	dfb	0,0,0,0,0,0,0,0
	dfb	96,192,0,0,0,0,192,96

	dfb	0,192,32,0,0,0,0,128
	dfb	0,0,0,0,0,0,2,1

	dfb	192,64,0,0,0,0,0,0
	dfb	1,0,0,8,8,12,0,0

	dfb	0,0,2,1,65,64,32,0
	dfb	0,0,0,0,0,0,0,0

locats	dw	61312
	dw	61564
	dw	61564
	dw	61560
	dw	61812
	dw	61552
	dw	61548
	dw	61548
	dw	61288
	dw	61292
	dw	61036
	dw	61040
	dw	60788
	dw	61048
	dw	61052
	dw	61308

; thrust/fire shapes
t1	dfb	192,192,224,224,192,192,192,192
	dfb	128,128,128,128,0,0,0,0
	dfb	3,3,7,7,3,3,3,3
	dfb	1,1,1,1,0,0,0,0

	dfb	0,0,0,112,124,124,248,248
	dfb	240,240,224,224,192,128,128,0
	dfb	0,0,0,0,0,0,0,0
	dfb	0,0,0,0,1,1,1,0

	dfb	0,128,192,224,224,192,128,0
	dfb	0,0,0,0,0,0,0,0
	dfb	0,1,3,7,7,15,31,30
	dfb	60,48,0,0,0,0,0,0

	dfb	0,0,0,0,128,128,128,0
	dfb	0,0,0,0,0,0,0,0
	dfb	0,0,3,15,31,127,255,252
	dfb	224,0,0,0,0,0,0,0

	dfb	0,12,255,255,255,255,12,0
	dfb	0,0,0,0,0,0,0,0
	dfb	0,0,0,15,15,0,0,0
	dfb	0,0,0,0,0,0,0,0

	dfb	0,0,0,0,0,128,128,128
	dfb	0,0,0,0,0,0,0,0
	dfb	0,0,0,224,252,255,127,31
	dfb	15,3,0,0,0,0,0,0

	dfb	0,0,0,0,0,0,0,0
	dfb	0,128,192,224,224,192,128,0
	dfb	0,0,0,0,0,0,48,60
	dfb	30,31,15,7,7,3,1,0

	dfb	0,128,128,192,224,224,240,240
	dfb	248,248,124,124,112,0,0,0
	dfb	0,1,1,1,0,0,0,0
	dfb	0,0,0,0,0,0,0,0

	dfb	128,128,128,128,192,192,192,192
	dfb	224,224,192,192,0,0,0,0
	dfb	1,1,1,1,3,3,3,3
	dfb	7,7,3,3,0,0,0,0

	dfb	0,128,128,128,0,0,0,0
	dfb	0,0,0,0,0,0,0,0
	dfb	0,1,1,3,7,7,15,15
	dfb	31,31,62,62,14,0,0,0

	dfb	0,0,12,60,120,248,240,224
	dfb	224,192,128,0,0,0,0,0
	dfb	0,0,0,0,0,1,3,7
	dfb	7,3,1,0,0,0,0,0

	dfb	0,0,0,7,63,255,254,248
	dfb	240,192,0,0,0,0,0,0
	dfb	0,0,0,0,0,1,1,1
	dfb	0,0,0,0,0,0,0,0

	dfb	0,0,0,240,240,0,0,0
	dfb	0,0,0,0,0,0,0,0
	dfb	0,48,255,255,255,255,48,0
	dfb	0,0,0,0,0,0,0,0

	dfb	0,0,192,240,248,254,255,63
	dfb	7,0,0,0,0,0,0,0
	dfb	0,0,0,0,1,1,1,0
	dfb	0,0,0,0,0,0,0,0

	dfb	0,128,192,224,224,240,248,120
	dfb	60,12,0,0,0,0,0,0
	dfb	0,1,3,7,7,3,1,0
	dfb	0,0,0,0,0,0,0,0

	dfb	0,0,0,0,0,0,0,0
	dfb	0,0,0,0,128,128,128,0
	dfb	0,0,0,14,62,62,31,31
	dfb	15,15,7,7,3,1,1,0

tlocs	dw	61312
	dw	61564
	dw	61564
	dw	61560
	dw	61812
	dw	61548
	dw	61540
	dw	61540
	dw	61284
	dw	61028
	dw	61032
	dw	61036
	dw	60788
	dw	61048
	dw	61052
	dw	61052

prevcvt	ds	1	; debouncer for convert key

snd	ds	1
grav	ds	1
collis	ds	1	; collision register
xpos	ds	1
xx	ds	1
xhi	ds	1

ypos	ds	1
yy	ds	1
yhi	ds	1

beaconhl ds	2		; for storage during beacon drawing...

blinkfuel ds	1		; blink your ship when low on fuel

xmove	ds	2
ymove	ds	1
ymvh	ds	1
rr	ds	3
dir	ds	1
key1	ds	1	; asdfghjk
key2	ds	1	; zxcvbnml
key8	ds	1	; enter, space, tab, etc.
key9	ds	1	; ctrl, shift, grph, code, numlock, capslock, etc.
ctr	ds	1
xp	ds	1
yp	ds	1
lx	ds	1
ly	ds	1
xt	ds	1
wave	ds	1
score	ds	2
fool	ds	1	; every other cycle, 'fool' tells if we will decrement
fuel	ds	1	; the 'fuel' variable (here).
curs	ds	2
holdit	ds	2
holdy	ds	2
hold	ds	2
oldx	ds	2
ptr1	ds	1
ptr2	ds	1
offs	ds	1
mv	ds	1
prev	ds	1
fahr	ds	1
yet	ds	1
cnt	ds	1
onsc	ds	1
numpad	ds	1
welc	ds	1
perf	ds	1		; number of "perfect" landings
ttlperf	ds	1
crashes	ds	2		; number of crashes
padf	ds	npad
pady	ds	npad
hold64	ds	64
gnd	ds	256
