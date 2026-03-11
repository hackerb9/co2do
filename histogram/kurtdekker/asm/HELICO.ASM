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

;; YOU WILL NEED TO REMOVE ALL COMMENTS IN ORDER TO COMPILE THIS ON AN ACTUAL
; Model 100 unit!
;
;*****************************************************************************
;
; Author:	Kurt W. Dekker
; Started:	Way back in 1985-1986
; Updated:	03/16/91
;		04/16/91
;		05/28/91
;		04/21/92
*		04/24/94
*		11/16/94
;
; Filename:	HELICO.ASM
;
; 03/16/91:	Center up the "tractor beam" that comes down so that it is
;		properly spaced between the two "you're screwed" bars.
;
; 04/16/91:	Try to determine why after the recompile on 03/16/91 there now
;		seems to be six (6) horizontal missiles available, instead of
;		the regular five (5) that the old game has.  I found it and
;		fixed it.  See PAT2<tab>
;
; 05/28/91:	Went in and identified the location where the guy who swoops
;		in from the side is handled.  Want to be able to NOP this guy
;		out easily, since he can be a pain.
;
; 04/21/92:	Moved the object data area up higher, then followed it with a
;		higher ORG address, saving approximately 750 bytes of memory.
;		It sounds silly, but it might be appreciated some day.  It
;		reminds me of the latest trend in PCs, of squeezing every tiny
;		drop of memory out of the PC by using a memory manager such as
;		QEMM386 or 386/MAX.  I laugh!
;
; 04/24/94:	Shareware notice added to main screen.
;
; 11/16/94:	Added in the DUMP.CO checker...
;
;*****************************************************************************
;

M1	=	0
MX1	=	5
M2	=	5
MX2	=	26
M3	=	26
MX3	=	59
BNV	=	100			; first bonus value
BNII	=	100			; first bonus increment
NUMBUL	=	5			; how many bullets you may fire
DATA	=	60000			; where our lookup table goes
DNUM	=	6			; bytes per object record

	ORG	55700

; this is all in file CHEKDUMP.INC!!!
; first test for presence of DUMP.CO
	ld	hl,62750
	ld	a,(hl)
	cmp	243
	jp	nz,nodump
	inc	hl
	ld	a,(hl)
	cmp	33
	jp	nz,nodump
	inc	hl
	ld	a,(hl)
	cmp	0
	jp	nz,nodump

	jmp	dumpok
nodump:
	mov	hl,nodumpmsg
	call	10161
dumpwait:
	ei
	call	29250
	cmp	0
	jp	z,dumpwait
	jmp	0

nodumpmsg:
	dm	Must load DUMP first!
	dfb	0

dumpok:
; end of CHEKDUMP.INC!

	LD	HL,0
	LD	(SCORE),HL
	ADD	HL,SP
	LD	(TMPSP),HL
	JP	KIZZ

ZZZ	CALL	ONETIM
NEXTHEL	CALL	INIT
	LD	HL,(TMPSP)
	LD	SP,HL
MAIN	LD	HL,SCINC
	LD	A,(HL)
	OR	A
	JP	Z,NSI
	DEC	(HL)
	LD	HL,(SCORE)
	INC	HL
	LD	(SCORE),HL
NSI	LD	A,(GGG)
	OR	A
	JP	Z,NOBL
	DEC	A
	LD	(GGG),A
	LD	BC,12850
	CALL	BE
NOBL	XOR	A
	LD	(65450),A
	CALL	PRSC
	CALL	KEYIN
	CALL	YOU
	LD	A,255
	LD	(MASK),A
	CALL	BLITZ
	CALL	RND
	CALL	62750
	CALL	ZRORQ
	JP	MAIN
BARS	LD	A,M3
	LD	(P),A
BAALP	LD	A,(P)
	CALL	LOAD
	CALL	BARS1
	LD	A,(P)
	CALL	SAVE
	LD	HL,P
	INC	(HL)
	LD	A,(HL)
	CP	MX3
	JP	NZ,BAALP
	RET
PRSC	LD	A,(SHIPS)
	LD	C,A
	LD	DE,60672
OKK:
	LD	HL,GSM
	LD	B,6
	CALL	LDIR
	DEC	C
	JP	NZ,OKK
	LD	HL,(BNS)
	EX	DE,HL
	LD	HL,(SCORE)
	RST	24
	JP	C,NOBNS
	CALL	DIFFINC
	LD	A,15
	LD	(GGG),A
	LD	HL,SHIPS
	INC	(HL)
	LD	HL,(BNI)
	ADD	HL,DE
	LD	(BNS),HL
	LD	HL,(BNI)
	LD	DE,BNII
	ADD	HL,DE
	LD	(BNI),HL
NOBNS	CALL	PRSC1
	XOR	A
	CALL	COUT
	RET
DIFFINC	LD	HL,FQA
	LD	A,(HL)
	ADD	15
	CP	150
	JP	NC,NUF1
	LD	(HL),A
NUF1	INC	HL
	LD	A,(HL)
	ADD	15
	CP	140
	JP	NC,NUF2
	LD	(HL),A
NUF2	INC	HL
	LD	A,(HL)
	ADD	15
	CP	110
	JP	NC,NUF3
	LD	(HL),A
NUF3	INC	HL
	LD	A,(HL)
	ADD	12
	CP	80
	JP	NC,NUF4
	LD	(HL),A
NUF4	INC	HL
	INC	(HL)
	LD	A,(HL)
	CP	14
	JP	NZ,NUF5
	DEC	(HL)
NUF5	RET
PRSC1	LD	HL,60928
	LD	(CSR),HL
	LD	HL,OUT1
	PUSH	HL
	LD	HL,(SCORE)
	CALL	14808
	RET
OUT1	INC	HL
OUTP	LD	A,(HL)
	OR	A
	RET	Z
	SUB	48
	PUSH	HL
	CALL	COUT
	POP	HL
	INC	HL
	JP	OUTP
COUT	LD	B,A
	ADD	A
	ADD	A
	ADD	B
	LD	E,A
	LD	D,0
	LD	HL,30561
	ADD	HL,DE
	LD	B,5
	EX	DE,HL
	LD	HL,(CSR)
OUTLP	LD	A,(DE)
	LD	(HL),A
	INC	L
	INC	DE
	DEC	B
	JP	NZ,OUTLP
	INC	L
	LD	(CSR),HL
	RET
CHECK8	LD	B,A
	LD	C,6
	LD	HL,STK
CHKLP	LD	A,(HL)
	SUB	B
	CP	10
	JP	C,SETTO1
	INC	HL
	DEC	C
	JP	NZ,CHKLP
	XOR	A
	RET
SETTO1	LD	A,1
	OR	A
	RET
SATEL	LD	A,(PC1)
	OR	A
	JP	NZ,DOSAT
	CALL	RND
	DEC	B
	JP	NZ,OUTLP
	INC	L
	LD	(CSR),HL
	RET
CHECK8	LD	B,A
	LD	C,6
	LD	HL,STK
CHKLP	LD	A,(HL)
	SUB	B
	CP	10
	JP	C,SETTO1
	INC	HL
	DEC	C
	JP	NZ,CHKLP
	XOR	A
	RET
SETTO1	LD	A,1
	OR	A
	RET
SATEL	LD	A,(PC1)
	OR	A
	JP	NZ,DOSAT
	CALL	RND
	CP	4
	RET	NC
	LD	A,1
	LD	(PC1),A
	LD	A,(SPD)
	AND	128
	JP	Z,USEL
	LD	A,234
	LD	(PC2),A
	CALL	RND
	AND	31
	LD	B,A
	CALL	RND
	AND	15
	ADD	B
	ADD	5
	LD	(PC3),A
	LD	A,(SPD)
	ADD	A
	SUB	2
	LD	(PC4),A
	JP	RESAT
USEL	XOR	A
	LD	(PC2),A
	CALL	RND
	AND	31
	LD	B,A
	CALL	RND
	AND	15
	ADD	B
	ADD	5
	LD	(PC3),A
	LD	A,(SPD)
	ADD	A
	ADD	2
	LD	(PC4),A
RESAT	CALL	RND
	AND	1
	ADD	A
	DEC	A
	LD	(PC5),A
DOSAT	LD	A,(ST1)
	OR	A
	JP	Z,NUGH
	LD	A,2
	LD	(ST1),A
NUGH	CALL	BUZZ
	LD	HL,(PC2)
	LD	(XP),HL
	LD	A,15
	LD	(SN),A
	XOR	A
	LD	(OO),A
	CALL	PLOT
	LD	A,(PC2)
	LD	C,255
	AND	128
	JP	Z,NGRAV
	LD	C,1
NGRAV	LD	A,(ISPD)
	LD	B,A
	LD	A,(PC4)
	ADD	C
	LD	(PC4),A
	LD	HL,PC2
	ADD	(HL)
	ADD	B
	SUB	C
	LD	(HL),A
	CP	236
	JP	C,HONO
HOYES	XOR	A
	LD	(PC1),A
	RET
HONO	LD	A,(PC5)
	LD	HL,PC3
	ADD	(HL)
	LD	(HL),A
	CP	57
	JP	NC,HOYES
	LD	A,1
	LD	(OO),A
	LD	HL,(PC2)
	LD	(XP),HL
	CALL	PLOT
	CALL	RND
	AND	3
	RET	NZ
	LD	A,1
	LD	(RQ4),A
	LD	HL,(PC2)
	INC	H
	INC	H
	LD	(POS4),HL
	RET

KOL	LD	A,(FLAG)
	OR	A
	JP	NZ,DOKOL
	LD	A,(RQ4)
	OR	A
	RET	Z
	LD	(FLAG),A
	XOR	A
	LD	(RQ4),A
	LD	HL,(POS4)
	LD	(X1),HL
	LD	A,L
	AND	128
	JP	NZ,PKM
	CALL	RND
	AND	3
	ADD	4
	LD	(XM),A
	JP	DOKOL
PKM	CALL	RND
	AND	3
	ADD	249
	LD	(XM),A
DOKOL	LD	A,14
	LD	(SN),A
	XOR	A
	LD	(OO),A
	LD	HL,(X1)
	LD	(XP),HL
	CALL	PLOT
	LD	A,(XM)
	LD	B,A
	LD	A,(ISPD)
	LD	HL,X1
	ADD	(HL)
	ADD	B
	LD	(HL),A
	CP	239
	JP	NC,BEND
	LD	HL,Y1
	CALL	RND
	AND	32
	JP	Z,DEVDIR
	LD	A,(UY)
	ADD	3
	CP	(HL)
	JP	C,DEVU
	JP	DEVIDN
DEVDIR	CALL	RND
	AND	128
	JP	Z,DEVIDN
DEVU	DEC	(HL)
	DEC	(HL)
DEVIDN	INC	(HL)
	LD	A,(HL)
	CP	61
	JP	NC,BEND
	LD	HL,(X1)
	LD	(XP),HL
	LD	A,1
	LD	(OO),A
	CALL	PLOT
	RET

BARS1	LD	A,(TY)
	CP	3
	JP	Z,KOL
	CP	2
	JP	Z,BULLET
	CP	1
	JP	Z,SHELL
	OR	A
	RET	NZ
	LD	A,(FLAG)
	OR	A
	JP	NZ,DOBAR
	LD	A,(RQ)
	OR	A
	RET	Z
	XOR	A
	LD	(RQ),A
	CPL
	LD	(FLAG),A
	LD	A,(POS)
	LD	(X1),A
	LD	A,53
	LD	(Y1),A
DOBAR	XOR	A
	LD	(OO),A
	LD	A,3
	LD	(SN),A
	LD	HL,(X1)
	LD	(XP),HL
	CALL	PLOT
	LD	A,(Y1)
	SUB	3
	LD	(Y1),A
	AND	128
	JP	Z,NOTEN1
MEND	XOR	A
	LD	(FLAG),A
	RET
NOTEN1	LD	A,(X1)
	LD	HL,ISPD
	ADD	(HL)
	LD	(X1),A
	CP	239
	JP	NC,MEND
	LD	A,1
	LD	(OO),A
	LD	HL,(X1)
	LD	(XP),HL
	JP	PLOT

BULLET	LD	A,(FLAG)
	OR	A
	JP	NZ,DOBULL
	LD	A,(RQ3)
	OR	A
	RET	Z
	DEC	A
	LD	(RQ3),A
	LD	A,1
	LD	(FLAG),A
	LD	A,54
	LD	(Y1),A
	LD	A,(POS3)
	LD	(X1),A
	CALL	RND
	AND	7
	ADC	0
	SUB	4
	LD	(XM),A
DOBULL	LD	A,10
	LD	(SN),A
	XOR	A
	LD	(OO),A
	LD	HL,(X1)
	LD	(XP),HL
	CALL	PLOT
	LD	A,(XM)
	LD	HL,ISPD
	ADD	(HL)
	LD	HL,X1
	ADD	(HL)
	LD	(HL),A
	CP	239
	JP	NC,BEND
	CALL	RND
	AND	3
	LD	B,A
	LD	A,(Y1)
	SUB	B
	LD	(Y1),A
	CP	63
	JP	NC,BEND
	LD	A,1
	LD	(OO),A
	LD	HL,(X1)
	LD	(XP),HL
	CALL	PLOT
	RET

SHELL	LD	A,(FLAG)
	OR	A
	JP	NZ,DOSHEL
	LD	A,(RQ1)
	OR	A
	RET	Z
	LD	(FLAG),A
	LD	A,(POS1)
	LD	(X1),A
	XOR	A
	LD	(RQ1),A
AGN3	CALL	RND
	AND	7
	SUB	3
	JP	Z,AGN3
	LD	(XM),A
	LD	A,56
	LD	(Y1),A
	CALL	RND
	AND	3
	ADD	248
	LD	B,A
	LD	(YM),A
	LD	A,56
	SUB	B
	INC	A
	LD	(FLAG),A
DOSHEL	XOR	A
	LD	(OO),A
	LD	A,5
	LD	(SN),A
	LD	HL,(X1)
	LD	(XP),HL
	CALL	PLOT
	LD	HL,SPD
	LD	A,(X1)
	SUB	(HL)
	LD	HL,XM
	ADD	(HL)
	LD	(X1),A
	CP	239
	JP	NC,BEND
	LD	A,(Y1)
	LD	HL,YM
	ADD	(HL)
	LD	(Y1),A
	INC	(HL)
	LD	HL,FLAG
	CP	(HL)
	JP	Z,BEND
	LD	HL,(X1)
	LD	(XP),HL
	LD	A,1
	LD	(OO),A
	JP	PLOT

; handles the "tractor beam" that comes down on you
STALAG	LD	A,(ST1)
	OR	A
	JP	NZ,DOSTA
	LD	A,(PSD)
	CP	6
	RET	NZ
	XOR	A
	LD	(ST2),A
	LD	A,1
	LD	(ST1),A
	CALL	RND
	AND	15
	ADD	36
	LD	(ST3),A		; the lowest point the tractor beam.
DOSTA	LD	A,13
	LD	(SN),A
	LD	A,115		; x position of tractor beam
	LD	(XP),A
	LD	A,(ST1)
	CP	2
	JP	Z,GROW
	LD	A,1
	LD	(OO),A
	LD	A,(ST2)
	LD	(YP),A
	CALL	PLOT
	LD	A,(ST2)
	LD	HL,ST3
	CP	(HL)	; has the tractor beam reached its lowest point?
	JP	Z,TURN
	INC	A
	LD	(ST2),A
	RET

TURN	LD	A,2
	LD	(ST1),A
GROW	LD	A,(ST2)
	LD	(YP),A
	XOR	A
	LD	(OO),A
	CALL	PLOT
	LD	A,(ST2)
	OR	A
	JP	Z,STOP
	DEC	A
	LD	(ST2),A
	RET

STOP	XOR	A
	LD	(ST1),A
	LD	(PSD),A
	RET

CRAFT	CALL	STALAG
	LD	A,M2
	LD	(P),A
CRALP	LD	A,(P)
	CALL	LOAD
	CALL	CRAFT1
	LD	A,(P)
	CALL	SAVE
	LD	HL,P
	INC	(HL)
	LD	A,(HL)
	CP	MX2
	JP	NZ,CRALP
	RET
DOBUNK	LD	HL,BUNKER
	LD	DE,SHTABS
	LD	B,16
	CALL	LDIR
	LD	A,54
	LD	(YP),A
	LD	HL,(X1)
	LD	A,H
	OR	A
	JP	NZ,NER2
	LD	A,L
	CP	229
	JP	NC,NER2
	LD	(XP),A
	XOR	A
	LD	(OO),A
	CALL	DUAL
NER2	LD	A,(ISPD)
	CALL	SETDE
	LD	HL,(X1)
	ADD	HL,DE
	CALL	CLIP
	LD	(X1),HL
	LD	A,H
	OR	A
	JP	NZ,NPL2
	LD	A,L
	CP	229
	JP	NC,NPL2
	LD	(XP),A
	LD	A,1
	LD	(OO),A
	CALL	DUAL
	CALL	RND
	LD	HL,FQD
	CP	(HL)
	JP	NC,NPL2
	CALL	RND
	AND	128
	JP	Z,LONPOL
	CALL	RND
	AND	3
	LD	(RQ3),A
	LD	A,(XP)
	LD	(POS3),A
	JP	NPL2
LONPOL	LD	A,1
	LD	(RQ),A
	LD	A,(XP)
	SUB	4
	LD	(POS),A
NPL2	CALL	RND
	LD	HL,FQE
	CP	(HL)
	RET	NC
	LD	HL,(X1)
	LD	(POS2),HL
	LD	A,1
	LD	(RQ2),A
	RET
DOART	LD	A,(FLAG)
	OR	A
	JP	NZ,DOART1
	LD	A,1
	LD	(FLAG),A
	CALL	RNDHL
	LD	(X1),HL
DOART1	LD	A,54
	LD	(YP),A
	LD	A,4
	LD	(SN),A
	LD	HL,(X1)
	LD	A,H
	OR	A
	JP	NZ,NER1
	LD	A,L
	CP	239
	JP	NC,NER1
	LD	(XP),A
	XOR	A
	LD	(OO),A
	CALL	PLOT
NER1	LD	A,(ISPD)
	CALL	SETDE
	LD	HL,(X1)
	ADD	HL,DE
	CALL	CLIP
	LD	(X1),HL
	LD	A,H
	OR	A
	JP	NZ,NPL1
	LD	A,L
	CP	239
	JP	NC,NPL1
	LD	(XP),A
	LD	A,1
	LD	(OO),A
	LD	A,(XP)
	CALL	CHECK8
	JP	Z,NOBLU1
	XOR	A
	LD	(FLAG),A
	CALL	SC2
	JP	SQUIRT
NOBLU1	CALL	PLOT
	CALL	RND
	LD	HL,FQC
	CP	(HL)
	JP	NC,NPL1
SQUIRT	LD	A,1
	LD	(RQ1),A
	LD	A,(X1)
	LD	(POS1),A
NPL1	RET
MENS	LD	A,(FLAG)
	OR	A
	JP	NZ,DOMAN
	LD	A,(RQ2)
	OR	A
	RET	Z
	LD	(FLAG),A
	XOR	A
	LD	(RQ2),A
	LD	HL,(POS2)
	LD	(X1),HL
	CALL	RND
	AND	1
	ADD	A
	DEC	A
	LD	(XM),A
DOMAN	LD	A,54
	LD	(YP),A
	LD	A,(YM)
	AND	3
	ADD	6
	LD	(SN),A
	LD	HL,(X1)
	LD	A,H
	OR	A
	JP	NZ,NER3
	LD	A,L
	CP	239
	JP	NC,NER3
	LD	(XP),A
	XOR	A
	LD	(OO),A
	CALL	PLOT
NER3	LD	HL,YM
	INC	(HL)
	LD	A,(HL)
	AND	3
	ADD	6
	LD	(SN),A
	LD	A,(XM)
	CALL	SETDE
	LD	HL,(X1)
	ADD	HL,DE
	LD	A,(ISPD)
	CALL	SETDE
	ADD	HL,DE
	CALL	CLIP
	LD	(X1),HL
	LD	A,H
	OR	A
	JP	NZ,NPL3
	LD	A,L
	CP	239
	JP	NC,NPL3
	LD	(XP),A
	CALL	CHECK8
	JP	Z,NOBLU
	XOR	A
	LD	(FLAG),A
	LD	A,NUMBUL
	LD	(RQ1),A
	LD	(RQ3),A
	LD	A,(XP)
	LD	(POS1),A
	LD	(POS3),A
	CALL	SC1
	RET
NOBLU	LD	A,1
	LD	(OO),A
	CALL	PLOT
	CALL	RND
	LD	HL,FQB
	CP	(HL)
	JP	NC,NPL3
	LD	A,1
	LD	(RQ1),A
	LD	A,(X1)
	LD	(POS1),A
NPL3	RET
SETDE	LD	D,0
	LD	E,A
	AND	128
	JP	Z,DE0
	LD	D,255
DE0	RET
CRAFT1	LD	A,(TY)
	CP	3
	JP	Z,MENS
	CP	2
	JP	Z,DOBUNK
	CP	1
	JP	Z,DOART
	OR	A
	RET	NZ
	LD	A,54
	LD	(YP),A
	LD	HL,CANON
	LD	DE,SHTABS
	LD	B,16
	CALL	LDIR
	LD	A,(FLAG)
	OR	A
	JP	NZ,DOCAN
	LD	HL,GENYET
	DEC	(HL)
	RET	NZ
	LD	(HL),25
	CPL
	LD	(FLAG),A
	LD	A,15
	LD	(YM),A
	CALL	RNDHL
	LD	(X1),HL
DOCAN	XOR	A
	LD	(OO),A
	LD	A,(Y1)
	OR	A
	JP	NZ,NOTEON
	LD	A,(X1)
	CP	239
	JP	NC,NOTEON
	LD	(XP),A
	CALL	DUAL
NOTEON	LD	A,(Y1)
	OR	A
	JP	NZ,DUNST
	LD	HL,STK
STSRCH	LD	A,(HL)
	CP	255
	JP	Z,DUNST
	LD	A,(X1)
	ADD	16
	SUB	(HL)
	CP	17
	JP	NC,NOHIT
	PUSH	HL
	CALL	SC4
	POP	HL
	LD	BC,7710
	CALL	BE
	LD	A,(YM)
	DEC	A
	JP	NZ,NOBEND
	LD	DE,POS
	LD	HL,RQ
	LD	A,(X1)
	ADD	4
	LD	(HL),1
	LD	(DE),A
	INC	HL
	INC	DE
	LD	(HL),1
	LD	(DE),A
	INC	HL
	INC	HL
	INC	DE
	INC	DE
	INC	DE
	LD	(HL),1
	LD	(DE),A
	INC	HL
	LD	(HL),1
	INC	DE
	LD	(DE),A
	INC	DE
	EX	DE,HL
	LD	(HL),54
	CALL	SC3
	JP	BEND
NOBEND	LD	(YM),A
NOHIT	INC	HL
	JP	STSRCH
DUNST	CALL	RND
	CP	13
	JP	NC,NODELT
AGN1	CALL	RND
	AND	3
	JP	Z,AGN1
	SUB	2
	LD	B,A
	ADD	A
	ADD	B
	LD	(XM),A
NODELT	LD	A,(XM)
	CALL	SETDE
	LD	HL,(X1)
	ADD	HL,DE
	CALL	CLIP
	LD	(X1),HL
	LD	A,(ISPD)
	CALL	SETDE
	LD	HL,(X1)
	ADD	HL,DE
	CALL	CLIP
	LD	(X1),HL
	LD	A,(Y1)
	OR	A
	JP	NZ,NOTPON
	LD	A,(X1)
	CP	239
	JP	NC,NOTPON
	LD	(XP),A
	LD	A,1
	LD	(OO),A
	CALL	DUAL
	LD	A,(X1)
	CP	70
	JP	C,NOTPON
	CP	150
	JP	NC,NOTPON
	CALL	RND
	LD	HL,FQA
	CP	(HL)
	JP	NC,NOTPON
	LD	A,1
	LD	(RQ),A
	LD	A,(X1)
	ADD	5
	LD	(POS),A
NOTPON	RET

BLITZ	LD	HL,STK
	LD	(STP),HL
	LD	B,6
ST0	LD	(HL),255
	INC	HL
	DEC	B
	JP	NZ,ST0
	LD	A,(KYS)
	AND	1
	LD	(FIRE),A
	LD	A,M1
	LD	(P),A
BLLP	LD	A,(P)
	CALL	LOAD
	CALL	BLITZ1
	LD	A,(P)
	CALL	SAVE
	LD	HL,P
	INC	(HL)
	LD	A,(HL)
	CP	MX1
	JP	NZ,BLLP
	RET

BLITZ1	LD	A,(FLAG)
	OR	A
	JP	NZ,DOBLI
	LD	A,(FIRE)
	OR	A
	RET	Z
	XOR	A
	LD	(FIRE),A
	LD	A,(UX)
	ADD	13
	LD	(X1),A
	LD	A,4
	LD	HL,SPD
	ADD	(HL)
	LD	(XM),A
	LD	A,(DIR)
	OR	A
	JP	Z,FACER
	LD	A,(UX)
	LD	(X1),A
	LD	A,252
	LD	HL,SPD
	ADD	(HL)
	LD	(XM),A
FACER	LD	A,(UY)
	ADD	4
	LD	(Y1),A
	LD	A,1
	LD	(FLAG),A
DOBLI	LD	HL,(X1)
	LD	(XP),HL
	XOR	A
	LD	(OO),A
	LD	A,2
	LD	(SN),A
	CALL	PLOT
	LD	A,(X1)
	LD	HL,SPD
	SUB	(HL)
	LD	HL,XM
	ADD	(HL)
	LD	(X1),A
	LD	A,(Y1)
	ADD	3
	LD	(Y1),A
	CP	57
	JP	C,NOTEND
	LD	HL,(STP)
	LD	A,(X1)
	LD	(HL),A
	INC	HL
	LD	(STP),HL
	LD	A,(Y1)
	CP	59
	JP	C,NOTEND
BEND	XOR	A
	LD	(FLAG),A
	RET

NOTEND	LD	A,(X1)
	CP	239
	JP	NC,BEND
	LD	HL,(X1)
	LD	(XP),HL
	LD	A,1
	LD	(OO),A
	JP	PLOT

; puts clouds on
FEATURE	LD	A,(OF1)
	AND	127
	LD	(XP),A
	LD	A,(OF2)
	LD	(YP),A
	LD	A,11
	LD	(SN),A
	XOR	A
	LD	(OO),A
	CALL	PLOT
	LD	A,(XP)
	ADD	128
	LD	(XP),A
	CALL	PLOT
	CALL	RND
	AND	32
	JP	Z,NOYMV
	LD	HL,OF2
	LD	C,(HL)
	DEC	(HL)
	CALL	RND
	AND	32
	JP	Z,NOKJH
	INC	(HL)
	INC	(HL)
NOKJH	LD	A,(HL)
	CP	40
	JP	C,NOYMV
	LD	(HL),C
NOYMV	LD	A,(OF2)
	LD	(YP),A
	LD	A,12
	LD	(SN),A
	LD	B,8
	LD	HL,TOLOD
	LD	DE,LODTO
RANDIT	CALL	RND
	AND	(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	DEC	B
	JP	NZ,RANDIT
	LD	A,(ISPD)
	LD	HL,OF1
	ADD	(HL)
	LD	(HL),A
	AND	127
	LD	(XP),A
	LD	A,1
	LD	(OO),A
	CALL	PLOT
	LD	A,(XP)
	ADD	128
	LD	(XP),A
	CALL	PLOT
	LD	H,244
	LD	A,(OFFSET)
	AND	31
	LD	L,A
	LD	DE,31
	LD	B,8
FELP	LD	A,(HL)
	AND	207
	LD	(HL),A
	INC	L
	LD	A,(HL)
	AND	207
	LD	(HL),A
	ADD	HL,DE
	DEC	B
	JP	NZ,FELP
	LD	A,(SPD)
	LD	B,A
	LD	A,(OFFSET)
	SUB	B
	LD	(OFFSET),A
	LD	H,244
	LD	A,(OFFSET)
	AND	31
	LD	L,A
	LD	DE,31
	LD	B,8
FELP1	LD	A,(HL)
	OR	48
	LD	(HL),A
	INC	L
	LD	A,(HL)
	OR	48
	LD	(HL),A
	ADD	HL,DE
	DEC	B
	JP	NZ,FELP1
	RET
DECODE	LD	A,(BRN)
	OR	A
	JP	Z,DODECO
	DEC	A
	LD	(BRN),A
	JP	Z,FULDED
RETD	CALL	BUZZ
	LD	A,(UY)
	CP	54
	JP	Z,NOFAL
	ADD	2
	LD	(UY),A
NOFAL	RET
DODECO	LD	A,(KY1)
	AND	128
	JP	Z,NOTL
	LD	A,1
	LD	(DIR),A
	LD	A,(SPD)
	DEC	A
	CP	250
	JP	Z,NOTR
	LD	(SPD),A
	JP	NOTR
NOTL	LD	A,(KY2)
	AND	128
	JP	Z,NOTR
	XOR	A
	LD	(DIR),A
	LD	A,(SPD)
	INC	A
	CP	6
	JP	Z,NOTR
	LD	(SPD),A
NOTR	LD	A,(KY1)
	AND	1
	JP	Z,NOTUP
	LD	A,(UY)
	CP	4
	JP	C,NOTUP
	SUB	2
	LD	(UY),A
NOTUP	LD	A,(KY2)
	AND	1
	JP	Z,NOTDN
	LD	A,(UY)
	CP	52
	JP	NZ,UCEL
	LD	A,(SPD)
	OR	A
	JP	Z,UCEL
	AND	128
	LD	HL,SPD
	JP	Z,CELU
	INC	(HL)
	INC	(HL)
CELU	DEC	(HL)
	JP	NOTDN
UCEL	LD	A,(UY)
	CP	54
	JP	NC,NOTDN
	ADD	2
	LD	(UY),A
NOTDN	LD	A,(UY)
	CP	54
	RET	NZ
	CALL	CHKDED
	XOR	A
	LD	(SPD),A
	RET
CHKDED	LD	A,(SPD)
	OR	A
	RET	Z
	CP	2
	RET	Z
	CP	1
	RET	Z
	CP	255
	RET	Z
	CP	254
	RET	Z
	JP	DEAD
FULDED	LD	A,(SCINC)
	LD	E,A
	LD	D,0
	LD	HL,(SCORE)
	ADD	HL,DE
	LD	(SCORE),HL
	LD	HL,SHIPS
	DEC	(HL)
	JP	NZ,NEXTHEL

KIZZ:
	LD	HL,MSG
	CALL	10161
	LD	HL,(SCORE)
	CALL	14804
	LD	A,48
	RST	32
WAIT:
	CALL	RND
	CALL	29250
	CP	13
	JP	NZ,WAIT
	JP	ZZZ

DEAD:
	CALL	RND
	CALL	62750
	XOR	A
	LD	(SPD),A
	LD	A,(BRN)
	OR	A
	RET	NZ
	LD	A,(UY)
	LD	B,A
	LD	A,56
	SUB	B
	RRC
	AND	127
	ADD	35
	LD	(BRN),A
	RET
ERA	LD	HL,60798
	LD	DE,60766
	LD	B,16
ERA1	LD	A,(HL)
	OR	192
	LD	(HL),A
	EX	DE,HL
	LD	A,(HL)
	OR	192
	LD	(HL),A
	EX	DE,HL
	INC	E
	INC	L
	DEC	B
	JP	NZ,ERA1
	RET
PLO	LD	HL,60798
	LD	DE,60766
	LD	B,16
PLO1	LD	A,(HL)
	AND	63
	LD	(HL),A
	EX	DE,HL
	LD	A,(HL)
	AND	63
	LD	(HL),A
	EX	DE,HL
	INC	E
	INC	L
	DEC	B
	JP	NZ,PLO1
	RET
YOU	LD	A,(SPD)
	OR	A
	JP	Z,TOHY
	LD	A,(UY)
	CP	14
	JP	C,TOHY
	CALL	PLO
	LD	A,(PSD)
	OR	A
	JP	Z,NOHY
	DEC	A
	LD	(PSD),A
	JP	NOHY
TOHY	CALL	ERA
	LD	HL,YETA
	DEC	(HL)
	JP	NZ,NOHY
	LD	(HL),5
	LD	HL,PSD
	LD	A,(HL)
	CP	6
	JP	Z,NOHY
	INC	(HL)
NOHY	LD	A,(BRN)
	OR	A
	JP	Z,NOSPEW
	CALL	BUZZ
	LD	A,(BRN)
	CP	35
	JP	NC,NOSPEW
	CALL	RND
	AND	4
	JP	Z,SPEWART
	LD	A,1
	LD	(RQ3),A
	CALL	RND
	AND	7
	LD	B,A
	LD	A,(UX)
	ADD	B
	LD	(POS3),A
	JP	NOSPEW
SPEWART	LD	A,1
	LD	(RQ1),A
	CALL	RND
	AND	7
	LD	B,A
	LD	A,(UX)
	ADD	B
	LD	(POS1),A
NOSPEW	XOR	A
	LD	(OO),A
	LD	A,(UX)
	LD	(XP),A
	LD	A,(UY)
	LD	(YP),A
	LD	A,(HMSK)
	LD	(MASK),A
	CALL	DIRSET
	CALL	DUAL
	LD	A,255
	LD	(MASK),A
	CALL	THEREST
	CALL	FLICKER
	LD	A,(UX)
	LD	(XP),A
	LD	A,(UY)
	LD	(YP),A
	LD	A,1
	LD	(OO),A
	LD	A,(HMSK)
	LD	(MASK),A
	LD	A,(BRN)
	OR	A
	JP	Z,NOJUNK
	LD	B,3
MOREJNK	CALL	RND
	AND	15
	LD	E,A
	LD	D,0
	LD	HL,SHTABS
	CALL	RND
	ADD	HL,DE
	LD	(HL),A
	DEC	B
	JP	NZ,MOREJNK
NOJUNK	LD	A,(BRN)
	OR	A
	JP	Z,YUK
	CP	25
	JP	C,YUK1
YUK	CALL	DUAL
YUK1	LD	A,(BIGCOL)
	OR	A
	JP	NZ,DEAD
	RET

THEREST	LD	HL,(SN)
	LD	(U1),HL
	CALL	FEATURE
;	CALL	SATEL
	CALL	CRAFT
	CALL	BARS
	LD	HL,(U1)
	LD	(SN),HL
	RET

DIRSET	LD	A,(DIR)
	AND	1
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LD	E,A
	LD	D,0
	LD	HL,HELI
	ADD	HL,DE
	LD	DE,SHTABS
	LD	B,16
	JP	LDIR

FLICKER	CALL	DECODE
	LD	A,(SPD)
	CPL
	INC	A
	LD	(ISPD),A
	CALL	DIRSET
	LD	HL,FL1
	INC	(HL)
	LD	A,(HL)
	AND	1
	LD	B,A
	LD	A,(HMSK)
	AND	254
	OR	B
	LD	(HMSK),A
	RET

; Puts ground on.
BACKGR	LD	HL,62464
BKLP	LD	(HL),128
	INC	L
	LD	(HL),64
	INC	L
	JP	NZ,BKLP
	RET

ONETIM	LD	HL,BNII
	LD	(BNI),HL
	LD	HL,BNV
	LD	(BNS),HL
	LD	HL,0
	LD	(SCORE),HL
	LD	A,4
	LD	(SHIPS),A
	RET

; General purpose initialize everything code.
INIT	LD	HL,FQA
	LD	(HL),25
	INC	HL
	LD	(HL),8
	INC	HL
	LD	(HL),18
	INC	HL
	LD	(HL),5
	INC	HL
	LD	(HL),3
	LD	A,255
	LD	(HMSK),A
	LD	A,110
	LD	(UX),A
	LD	A,54
	LD	(UY),A
	LD	A,4
	LD	(OFFSET),A
	LD	A,20
	LD	(OF2),A
	XOR	A
	LD	(SCINC),A
	LD	(PC1),A
	LD	(GGG),A
	LD	(ST1),A
	LD	(PSD),A
	LD	(BRN),A
	LD	(BUPO),A		; bunker positioning
	LD	(FIRE),A
	LD	(SPD),A
	CALL	ZRORQ
	LD	A,1
	LD	(GENYET),A
	LD	(YETA),A
	LD	HL,60672
	LD	DE,60673
	LD	BC,2047
	LD	(HL),0
	CALL	27611
	CALL	BACKGR
	XOR	A
	LD	(FLAG),A
	LD	A,M1
	LD	(P),A
JL1	LD	A,(P)
	CALL	SAVE
	LD	HL,P
	INC	(HL)
	LD	A,(HL)
	CP	MX1
	JP	NZ,JL1
	XOR	A
	LD	(XM),A
	LD	(FLAG),A
	LD	A,M2
	LD	(P),A
	LD	HL,PAT1
JL2	LD	A,(HL)
	LD	(TY),A
	INC	HL
	PUSH	HL
	CP	2			; is this a bunker?
	JP	NZ,NOTBU
	LD	HL,BUPO
	INC	(HL)
	LD	H,(HL)
	LD	L,0
	LD	(X1),HL
NOTBU	LD	A,(P)
	CALL	SAVE
	LD	HL,P
	INC	(HL)
	LD	A,(HL)
	POP	HL
	CP	MX2
	JP	NZ,JL2
	XOR	A
	LD	(FLAG),A
	LD	(TY),A
	LD	A,M3
	LD	(P),A
	LD	HL,PAT2
JL3	LD	A,(HL)
	LD	(TY),A
	INC	HL
	PUSH	HL
	LD	A,(P)
	CALL	SAVE
	LD	HL,P
	INC	(HL)
	LD	A,(HL)
	POP	HL
	CP	MX3
	JP	NZ,JL3
	RET

DUAL	XOR	A
	LD	(SN),A
	CALL	PLOT
	LD	A,(CLS)
	LD	(BIGCOL),A
	LD	A,(XP)
	ADD	8
	LD	(XP),A
	LD	A,1
	LD	(SN),A
	CALL	PLOT
	LD	A,(CLS)
	LD	HL,BIGCOL
	OR	(HL)
	LD	(HL),A
	RET

PLOT	LD	C,0
	LD	B,8
	LD	A,(SN)
	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,SHTABS
	ADD	HL,DE
	LD	(SHPTR),HL
	LD	A,(YP)
	RRC
	RRC
	RRC
	AND	7
	ADD	237
	LD	H,A
	LD	A,(XP)
	LD	L,A
	LD	(SCPTR),HL
PLOTLP	LD	HL,(SHPTR)
	LD	A,(HL)
	INC	HL
	LD	(SHPTR),HL
	LD	L,A
	LD	A,(MASK)
	AND	L
	LD	L,A
	LD	H,0
	LD	A,(YP)
	AND	7
	JP	Z,NOROT
ROTLP	ADD	HL,HL
	DEC	A
	JP	NZ,ROTLP
NOROT	EX	DE,HL
	LD	HL,(SCPTR)
	LD	A,(OO)
	OR	A
	JP	Z,ERASE
	LD	A,(HL)
	AND	E
	OR	C
	LD	C,A
	LD	A,(HL)
	OR	E
	LD	(HL),A
	INC	H
	LD	A,H
	CP	245
	JP	Z,END1
	LD	A,(HL)
	AND	D
	OR	C
	LD	C,A
	LD	A,(HL)
	OR	D
	LD	(HL),A
END1	LD	HL,(SCPTR)
	INC	L
	LD	(SCPTR),HL
	DEC	B
	JP	NZ,PLOTLP
	LD	A,C
	LD	(CLS),A
	RET

ERASE	LD	A,E
	CPL
	AND	(HL)
	LD	(HL),A
	INC	H
	LD	A,H
	CP	245
	JP	Z,END1
	LD	A,D
	CPL
	AND	(HL)
	LD	(HL),A
	JP	END1

RNDHL	CALL	RND
	LD	H,A
	CALL	RND
	LD	L,A
	CALL	CLIP
	LD	A,H
	OR	A
	JP	Z,RNDHL
	RET

RND	PUSH	HL
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

; Universal "beep" routine.
BE	DI
	LD	A,C
BF	DEC	A
	JP	NZ,BF
	CALL	CLICK
	DEC	B
	JP	NZ,BE
	RET

BUZZ	LD	A,30
BUZL	PUSH	AF
	CALL	RND
	AND	4
	CALL	Z,CLICK
	POP	AF
	DEC	A
	JP	NZ,BUZL
	RET

CLICK	LD	A,(SND)
	OR	A
	RET	Z
	JP	30326

KEYIN	DI
	LD	A,255
	OUT	177
	IN	178
	AND	254
	OUT	178
	IN	225
	CPL
	AND	16
	JP	NZ,KEYIN
	IN	225
	CPL
	AND	32
	LD	(SND),A
	IN	178
	OR	1
	OUT	178
	LD	A,191
	OUT	177
	IN	225
	CPL
	LD	(KYS),A
	LD	A,254
	OUT	177
	IN	225
	CPL
	LD	(KY2),A
	LD	A,253
	OUT	177
	IN	225
	CPL
	LD	(KY1),A
	RET

CLIP	LD	A,H
	AND	3
	LD	H,A
	RET

MULT	LD	E,L
	LD	D,H
	ADD	HL,HL
	ADD	HL,DE
	ADD	HL,HL
	RET

LOAD	LD	L,A
	LD	H,0
	CALL	MULT
	LD	DE,DATA
	ADD	HL,DE
	LD	DE,FLAG
	LD	B,DNUM
	JP	LDIR

SAVE	LD	L,A
	LD	H,0
	CALL	MULT
	LD	DE,DATA
	ADD	HL,DE
	LD	DE,FLAG
	LD	B,DNUM
	EX	DE,HL
LDIR	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	DEC	B
	JP	NZ,LDIR
	RET

ZRORQ	XOR	A
	LD	B,5
	LD	HL,RQ
KRQ	LD	(HL),A
	INC	HL
	DEC	B
	JP	NZ,KRQ
	RET
SC1	LD	BC,8995
	CALL	BE
	LD	HL,SCINC
	LD	A,(HL)
	ADD	10
	LD	(HL),A
	RET
SC2	LD	BC,5155
	CALL	BE
	LD	HL,SCINC
	LD	A,(HL)
	ADD	5
	LD	(HL),A
	RET
SC3	LD	BC,5140
	CALL	BE
	LD	HL,SCINC
	LD	A,(HL)
	ADD	25
	LD	(HL),A
	RET
SC4	LD	HL,SCINC
	INC	(HL)
	RET

; Pre-slotted locations for the aliens themselves.
; 0 - tanks?
; 1 - artillery?
; 2 - bunkers
; 3 - stompers
PAT1	DFB	0,0,0,0,0,1,1,1,1,2,2,2
	DFB	3,3,3,3,3,3,3,3,3

; Pre-slotted locations for the alien shots.
; 0 - MX missiles?
; 1 - artillery?
; 2 - X-marks
; 3 - air-to-air missiles.
PAT2	DFB	0,0,0,0,0,0,1,1,1,1,1,1
	DFB	2,2,2,2,2,2,2,2,2
	DFB	2,2,2,2,2,2,2,3,3,3,3,3

GSM	DFB	40,120,40,32,56,0

MSG	DFB	12,27,112
	DM	'Copter Strike
	DFB	27,113
	DM	 - Shareware!!!
	DFB	13,10,10
	DM	Send $5 Reg To:  Kurt W. Dekker
	DFB	13,10,9,9
	DM	PO Box 10342
	DFB	13,10,9,9
	DM	Costa Mesa, CA  92627
	DFB	13,10,10
	DM	Started: 11/22/85 (in college)
	DFB	13,10
	DM	SCORE:
	DFB	0
SHTABS	DS	16
	DFB	2,7,2,0,0,0,0,0
	DFB	0,128,120,199,120,128,0,0
	DFB	224,64,96,112,112,96,64,224
	DFB	0,0,24,60,60,24,0,0
	DFB	8,148,252,148,52,52,52,8
	DFB	8,84,116,92,84,116,84,8
	DFB	8,52,52,52,156,244,148,8
	DFB	8,84,116,84,84,124,84,8
	DFB	0,0,36,24,24,36,0,0
TOLOD	DFB	60,126,255,255,255,255,126,60
LODTO	DS	8
	DFB	1,3,1,7,1,3,1,0
	DFB	1,1,1,1,1,1,1,1
	DFB	4,10,19,7,7,19,10,4
HELI	DFB	4,30,20,16,16,17,81,145
	DFB	185,237,175,173
	DFB	233,169,145,65
	DFB	65,145,169,233
	DFB	173,175,237,185
	DFB	145,81,17,16,16,20,30,4
CANON	DFB	32,112,208,152,191,164
	DFB	180,150,182,164,180,159
	DFB	152,208,112,32
BUNKER	DFB	247,149,157,129,157,149
	DFB	149,157,129,157,149,149
	DFB	157,129,157,247
PC1	DS	1
PC2	DS	1
PC3	DS	1
PC4	DS	1
PC5	DS	1
FQA	DS	1
FQB	DS	1
FQC	DS	1
FQD	DS	1
FQE	DS	1
GGG	DS	1
SND	DS	1
BRN	DS	1
GENYET	DS	1
BUPO	DS	1
RQ	DS	1
RQ1	DS	1
RQ2	DS	1
RQ3	DS	1
RQ4	DS	1
POS	DS	1
POS1	DS	1
POS2	DS	2
POS3	DS	1
POS4	DS	2
PSD	DS	1
PREV	DS	1
FIRE	DS	1
YETA	DS	1
DIR	DS	1
UX	DS	1
UY	DS	1
ST1	DS	1
ST2	DS	1
ST3	DS	1
SHIPS	DS	1
BNI	DS	2
BNS	DS	2
CSR	DS	2
SCINC	DS	1
SCORE	DS	2
TMPSP	DS	2
SN	DS	1
XP	DS	1
YP	DS	1
OO	DS	1
CLS	DS	1
BIGCOL	DS	1
MASK	DS	1
SCPTR	DS	2
SHPTR	DS	2
U1	DS	2
STP	DS	2
KY1	DS	1
KY2	DS	1
KYS	DS	1
STK	DS	6
P	DS	1		; Used for pointing into tables (just a #)
RR	DS	3
FL1	DS	1
HMSK	DS	1
OF1	DS	1
OF2	DS	1
OFFSET	DS	1
ISPD	DS	1
SPD	DS	1

; These bytes are LOADed and SAVEd as the "work area" for any given shape.
FLAG	DS	1
X1	DS	1
Y1	DS	1
XM	DS	1
YM	DS	1
TY	DS	1
