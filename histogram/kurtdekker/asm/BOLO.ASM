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
MAZE	=	60416
UPDATE	=	62750

	ORG	59600
	LD	HL,MAZE
	LD	B,0
INITLP	CALL	RND
	LD	C,A
	CALL	RND
	AND	C
	LD	(HL),A
	INC	HL
	DEC	B
	JP	NZ,INITLP
	LD	A,0
	LD	(YOUX),A
	LD	(YOUY),A
	LD	A,8
	LD	(XFLOT),A
	LD	(YFLOT),A
	LD	HL,MAZE
MAINLP	LD	A,0
	LD	(XOFF),A
	LD	(YOFF),A
	CALL	CLS1
PICLOOP	CALL	GETBYTE
	LD	(BYTE),A
	AND	1
	JP	Z,NOTOP
	CALL	SETXY
SQLOOP1	CALL	CALC
	OR	A
	JP	Z,NOPL1
	OR	(HL)
	LD	(HL),A
NOPL1	LD	HL,XPOS
	INC	(HL)
	DEC	C
	LD	A,C
	OR	A
	JP	NZ,SQLOOP1
NOTOP	LD	A,(BYTE)
	AND	2
	JP	Z,NOSIDE
	CALL	SETXY
SQLOOP2	CALL	CALC
	OR	A
	JP	Z,NOPL2
	OR	(HL)
	LD	(HL),A
NOPL2	LD	HL,YPOS
	INC	(HL)
	DEC	C
	LD	A,C
	OR	A
	JP	NZ,SQLOOP2
NOSIDE	LD	HL,XOFF
	INC	(HL)
	LD	A,(HL)
	CP	5
	JP	NZ,NORESET
	LD	(HL),0
	LD	HL,YOFF
	INC	(HL)
	LD	A,(HL)
	CP	5
NORESET	JP	NZ,PICLOOP
	LD	A,31
	LD	(XPOS),A
	LD	(YPOS),A
	CALL	CALC
	PUSH	AF
	AND	(HL)
	JP	Z,LIVE
	POP	AF
	RET
LIVE	POP	AF
	OR	(HL)
	LD	(HL),A
	CALL	UPDATE
	LD	A,1
	LD	(GOON),A
KEYIN	DI
	IN	178
	OR	3
	OUT	178
	LD	A,253
	OUT	177
	IN	225
	XOR	255
	AND	4
	JP	Z,NOINCX
	LD	HL,XFLOT
	INC	(HL)
	LD	A,(HL)
	AND	15
	LD	(HL),A
	JP	NZ,NOINCX
	LD	HL,YOUX
	INC	(HL)
NOINCX	IN	225
	XOR	255
	AND	2
	JP	Z,NODECX
	LD	HL,XFLOT
	DEC	(HL)
	LD	A,(HL)
	AND	15
	LD	(HL),A
	CP	15
	JP	NZ,NODECX
	LD	HL,YOUX
	DEC	(HL)
NODECX	IN	225
	XOR	255
	AND	1
	JP	Z,NODECY
	LD	HL,YFLOT
	DEC	(HL)
	LD	A,(HL)
	AND	15
	LD	(HL),A
	CP	15
	JP	NZ,NODECY
	LD	HL,YOUY
	DEC	(HL)
NODECY	LD	A,254
	OUT	177
	IN	225
	XOR	255
	AND	1
	JP	Z,NOINCY
	LD	HL,YFLOT
	INC	(HL)
	LD	A,(HL)
	AND	15
	LD	(HL),A
	JP	NZ,NOINCY
	LD	HL,YOUY
	INC	(HL)
NOINCY	LD	A,(GOON)
	OR	A
	LD	A,1
	LD	(GOON),A
	JP	Z,KEYIN
	JP	MAINLP
SETXY	LD	A,(XOFF)
	AND	15
	RLCA
	RLCA
	RLCA
	RLCA
	LD	HL,XFLOT
	SUB	(HL)
	LD	(XPOS),A
	LD	A,(YOFF)
	AND	15
	RLCA
	RLCA
	RLCA
	RLCA
	LD	HL,YFLOT
	SUB	(HL)
	LD	(YPOS),A
	LD	C,17
	RET
GETBYTE	LD	A,(YOUY)
	LD	L,A
	LD	A,(YOFF)
	ADD	L
	AND	15
	LD	L,A
	LD	H,0
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	ADD	HL,HL
	LD	A,(YOUX)
	LD	E,A
	LD	A,(XOFF)
	ADD	E
	AND	15
	LD	E,A
	LD	D,0
	ADD	HL,DE
	LD	DE,MAZE
	ADD	HL,DE
	LD	A,(HL)
	RET
RND	PUSH	HL
	LD	HL,RR
	ADC	(HL)
	LD	(HL),A
	INC	HL
	ADC	(HL)
	LD	(HL),A
	SCF
	INC	HL
	ADC	(HL)
	LD	(HL),A
	POP	HL
	RET

CALC	LD	A,(XPOS)
	CP	63
	JP	NC,ZERRET
	LD	E,A
	LD	A,(YPOS)
	CP	63
	JP	NC,ZERRET
	AND	56
	RRCA
	RRCA
	RRCA
	LD	D,A
	LD	HL,60672
	ADD	HL,DE
	PUSH	HL
	LD	A,(YPOS)
	AND	7
	LD	E,A
	LD	D,0
	LD	HL,BITS
	ADD	HL,DE
	LD	A,(HL)
	POP	HL
	RET
ZERRET	LD	HL,0
	LD	A,0
	RET
CLS1	LD	HL,60672
	LD	B,8
CLLP	LD	(HL),0
	INC	HL
	LD	A,L
	CP	64
	JP	NZ,CLLP
	LD	L,0
	INC	H
	DEC	B
	JP	NZ,CLLP
	RET
CLS	LD	HL,60672
	LD	DE,60673
	LD	BC,2047
	LD	(HL),0
	CALL	LDIR
	RET
LDIR	PUSH	AF
LDLOOP	LD	A,(HL)
	LD	(DE),A
	INC	HL
	INC	DE
	DEC	BC
	LD	A,B
	OR	C
	JP	NZ,LDLOOP
	POP	AF
	RET
BITS	DFB	1
	DFB	2
	DFB	4
	DFB	8
	DFB	16
	DFB	32
	DFB	64
	DFB	128
XPOS	DS	1
YPOS	DS	1
RR	DS	3
YOUX	DS	1
YOUY	DS	1
XFLOT	DS	1
YFLOT	DS	1
XOFF	DS	1
YOFF	DS	1
BYTE	DS	1
GOON	DS	1
