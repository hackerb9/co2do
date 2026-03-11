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
; (Sorry, I have no idea what this is, but I _THINK_ it is a flood-fill routine
;  that I wrote one night while sitting at the University of Hawaii Manoa
;  library... but I'm not sure...)
;

	AND	1
	JP	NZ,ZZZ
	LD	A,B
	AND	2
	JP	Z,MAIN
	LD	A,1
	LD	(DONT),A
	JP	MAIN

QUIT	CALL	62750
	CALL	FILL
;	LD	A,7
;	CALL	POZ
;	JP	INTER
	LD	A,50
WAIT	PUSH	AF
	CALL	62750
	LD	HL,60672
	INC	(HL)
	POP	AF
	DEC	A
	JP	NZ,WAIT
INTER	LD	A,4
	CALL	POZ
	JP	ZZZ

FILL	LD	A,32
	LD	(X1),A
	LD	(Y1),A
	LD	A,1
	LD	(YM),A
	LD	HL,65535
	LD	(STACKP),HL
	CALL	PUSH
FILLP	CALL	ONEDEEP
	LD	HL,(STACKP)
	LD	A,H
	CP	255
	RET	Z
	DEC	HL
	LD	(STACKP),HL
	CALL	LD1
	LD	A,1
	LD	(YM),A
	LD	A,(Y1)
	LD	B,A
	AND	127
	LD	(Y1),A
	LD	A,B
	AND	128
	JP	Z,FILLP
	LD	A,255
	LD	(YM),A
	JP	FILLP

ONEDEEP	NOP
	LD	A,(X1)
	CP	240
	RET	NC
	XOR	A
	LD	(CHEKL),A
	LD	(CHEKR),A
START	LD	HL,(X1)
	LD	(XP),HL
	CALL	TEST
	RET	NZ
	CALL	PSET
	LD	HL,(X1)
	LD	(XP),HL
	LD	HL,XP
	INC	(HL)	**
	CALL	TEST
	JP	NZ,ONR
	LD	A,(CHEKR)
	OR	A
	JP	NZ,NOTONR
	CPL
	LD	(CHEKR),A
	CALL	STO
	LD	HL,(XP)
	LD	(X1),HL
	CALL	PUSH
	CALL	RCL
	JP	NOTONR
ONR	LD	A,(YM)
	LD	HL,YP
	ADD	(HL)
	LD	(HL),A
	CALL	TEST
	JP	NZ,NOTONR
	CALL	STO
	LD	HL,(XP)
	LD	(X1),HL
	CALL	PUSH
	CALL	RCL
NOTONR	LD	HL,(X1)
	LD	(XP),HL
	LD	HL,XP
	DEC	(HL)	**
	CALL	TEST
	JP	NZ,ONL
	LD	A,(CHEKL)
	OR	A
	JP	NZ,NOTONL
	CPL
	LD	(CHEKL),A
	CALL	STO
	LD	HL,(XP)
	LD	(X1),HL
	CALL	PUSH
	CALL	RCL
	JP	NOTONL
ONL	LD	A,(YM)
	LD	HL,YP
	ADD	(HL)
	LD	(HL),A
	CALL	TEST
	JP	NZ,NOTONL
	CALL	STO
	LD	HL,(XP)
	LD	(X1),HL
	CALL	PUSH
	CALL	RCL
NOTONL	LD	HL,(X1)
	LD	(XP),HL
	LD	A,(YP)
	LD	HL,YM
	SUB	(HL)
	LD	(YP),A
	CALL	TEST
	JP	NZ,NOOPP
	CALL	STO
	LD	HL,(XP)
	LD	(X1),HL
	LD	A,(YM)
	LD	B,A
	XOR	A
	SUB	B
	LD	(YM),A
	CALL	PUSH
	CALL	RCL
NOOPP	LD	A,(YM)
	LD	HL,Y1
	ADD	(HL)
	LD	(HL),A
	CP	63
	JP	C,START
	RET

PUSH	LD	A,(YM)
	CP	1
	JP	Z,NOADBIT
	LD	A,(Y1)
	OR	128
	LD	(Y1),A
NOADBIT	LD	HL,(STACKP)
	CALL	SV1
	LD	HL,(STACKP)
	INC	HL
	LD	(STACKP),HL
	RET

CALC	LD	A,(XP)
	LD	L,A
	LD	A,(YP)
	RRC
	RRC
	RRC
	AND	7
	ADD	237
	LD	H,A
	PUSH	HL
	LD	A,(YP)
	AND	7
	LD	E,A
	LD	D,0
	LD	HL,BITS
	ADD	HL,DE
	LD	A,(HL)
	POP	HL
	RET

POZ	LD	B,A
POZ1	LD	HL,0
POZ2	DEC	HL
	LD	A,H
	OR	L
	JP	NZ,POZ2
	DEC	B
	JP	NZ,POZ1
	RET

TEST	CALL	CALC
	AND	(HL)
	RET

PSET	CALL	CALC
	OR	(HL)
	LD	(HL),A
	LD	HL,(XP)
	LD	E,H
	LD	D,L
*	JP	29772
;	LD	A,E
;	ADD	D
;	AND	1
;	JP	Z,29772
;	RET
	LD	A,E
	AND	1
	LD	B,A
	LD	A,D
	AND	1
	OR	B
	CALL	Z,29772
	RET

STO	LD	HL,X1
	LD	DE,DEST
	LD	B,4
	JP	LDIR

RCL	LD	HL,DEST
	LD	DE,X1
	LD	B,4
	JP	LDIR

OBJ	XOR	A
	LD	(PTR),A
OBJL	LD	A,(PTR)
	CALL	LOAD
	CALL	OBJ1
	LD	A,(PTR)
	CALL	SAVE
	LD	HL,PTR
	INC	(HL)
	LD	A,(HL)
	CP	MAXOB
	JP	NZ,OBJL
	RET

OBJ1	LD	HL,(X1)
	LD	(XP),HL
	XOR	A
	LD	(ONOFF),A
	LD	(SHNUM),A
	CALL	PLOT
	LD	A,(XM)
	LD	HL,X1
	ADD	(HL)
	CP	236
	JP	C,NOBNCX
	CALL	BNCX
	LD	A,(HL)
NOBNCX	LD	(HL),A
	LD	A,(YM)
	LD	HL,Y1
	ADD	(HL)
	CP	59
	JP	C,NOBNCY
	CALL	BNCY
	LD	A,(HL)
NOBNCY	LD	(HL),A
	LD	HL,(X1)
	LD	(XP),HL
	LD	A,1
	LD	(ONOFF),A
	LD	A,(DONT)
	OR	A
	CALL	PLOT
	LD	A,(COLLIS)
	OR	A
	RET	Z
	CALL	RND
	AND	32
	JP	Z,GY
GX	CALL	RNDM
	LD	(XM),A
	RET
GY	CALL	RNDM
	LD	(YM),A
	RET
BNCX	LD	A,(XM)
	LD	B,A
	XOR	A
	SUB	B
	LD	(XM),A
	RET

BNCY	LD	A,(YM)
	LD	B,A
	XOR	A
	SUB	B
	LD	(YM),A
	RET

LD1	ADD	HL,HL
	LD	DE,DATA
	ADD	HL,DE
	LD	DE,X1
	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	LD	A,(HL)
	LD	(DE),A
	RET

SV1	ADD	HL,HL
	LD	DE,DATA
	ADD	HL,DE
	LD	DE,X1
	LD	A,(DE)
	LD	(HL),A
	INC	HL
	INC	DE
	LD	A,(DE)
	LD	(HL),A
	RET

LOAD	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	LD	DE,DATA
	ADD	HL,DE
	LD	DE,X1
	LD	B,4
LDIR	LD	A,(HL)
	LD	(DE),A
	INC	DE
	INC	HL
	DEC	B
	JP	NZ,LDIR
	RET

SAVE	LD	L,A
	LD	H,0
SV1	ADD	HL,HL
	ADD	HL,HL
	LD	DE,DATA
	ADD	HL,DE
	LD	DE,X1
	LD	B,4
	EX	DE,HL
	JP	LDIR

PLOT	LD	C,0
	LD	B,8
	LD	A,(SHNUM)
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
	LD	H,0
	LD	A,(YP)
	AND	7
	JP	Z,NOROT
ROTLP	ADD	HL,HL
	DEC	A
	JP	NZ,ROTLP
NOROT	EX	DE,HL
	LD	HL,(SCPTR)
	LD	A,(ONOFF)
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
	LD	(COLLIS),A
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

CLS	LD	HL,60672
	LD	DE,60673
	LD	BC,2047
	LD	(HL),255
	JP	27611

INIT	LD	HL,60672
	LD	(POS),HL
	XOR	A
	LD	(DONT),A
	LD	(PTR),A
INLP	CALL	RND
	CP	235
	JP	NC,INLP
	LD	(X1),A
AGEN	CALL	RND
	AND	63
	CP	57
	JP	NC,AGEN
	LD	(Y1),A
	CALL	RNDM
	LD	(XM),A
	CALL	RNDM
	LD	(YM),A
	LD	A,(PTR)
	CALL	SAVE
	LD	HL,PTR
	INC	(HL)
	LD	A,(HL)
	CP	MAXOB
	JP	NZ,INLP
	CALL	CLS
;	LD	A,254
;	LD	(61728),A
	RET

RNDM	CALL	RND
	AND	7
	JP	Z,RNDM
	SUB	4
	JP	Z,RNDM
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

CCC	DFB	231,165,165,0

SHTABS	DFB	14,31,31,31,14,0,0,0,0

BITS	DFB	1,2,4,8,16,32,64,128

RR	DS	3

XP	DS	1
YP	DS	1
COLLIS	DS	1
SHNUM	DS	1
ONOFF	DS	1
SCPTR	DS	2
SHPTR	DS	2

X1	DS	1
Y1	DS	1
XM	DS	1
YM	DS	1

PTR	DS	1

POS	DS	2

XD	DS	1
YD	DS	1
STACKP	DS	2
CHEKL	DS	1
CHEKR	DS	1

DEST	DS	4
DONT	DS	1
