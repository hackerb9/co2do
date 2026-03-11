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
MAXROCK	=	32
	ORG	58000
	LD	HL,60672
	LD	DE,60673
	LD	BC,2047
	LD	(HL),0
	CALL	27611
	CALL	DOROK
	LD	A,0
	OUT	177
	IN	225
	CPL
	JP	Z,NOINC
	LD	HL,OFF
	INC	(HL)
	INC	(HL)
NOINC	CALL	62750
	JP	MAIN
DOROK	XOR	A
	LD	(PTR),A
ROCKLP	LD	A,(PTR)
	CALL	SETDE
	LD	HL,XM
	ADD	HL,DE
	LD	A,(HL)
	LD	HL,XS
	ADD	HL,DE
	ADD	(HL)
	LD	(HL),A
	LD	(XP),A
	LD	HL,YM
	ADD	HL,DE
	LD	A,(HL)
	LD	HL,YS
	ADD	HL,DE
	ADD	(HL)
	LD	(HL),A
	LD	HL,OFF
	ADD	(HL)
	CP	63
	JP	NC,NOTOK
	LD	(YP),A
	LD	HL,SZ
	ADD	HL,DE
	LD	A,(XP)
	ADD	(HL)
	LD	(XQ),A
	LD	A,(YP)
	ADD	(HL)
	CP	62
	JP	C,OK
	LD	A,62
OK	LD	(YQ),A
	CALL	SLAM
NOTOK	LD	HL,PTR
	INC	(HL)
	LD	A,(HL)
	CP	MAXROCK
	JP	NZ,ROCKLP
	RET
INIT	XOR	A
	LD	(OFF),A
	LD	(PTR),A
INLP	LD	A,(PTR)
	CALL	SETDE
	LD	HL,XS
	ADD	HL,DE
	CALL	RND
	LD	(HL),A
	LD	HL,YS
	ADD	HL,DE
	CALL	RND
	LD	(HL),A
	LD	HL,XM
	ADD	HL,DE
	CALL	RND1
	LD	(HL),A
	LD	HL,YM
	ADD	HL,DE
	CALL	RND1
	LD	(HL),A
	LD	HL,SZ
	ADD	HL,DE
	CALL	RND
	AND	7
	ADD	15
	LD	(HL),A
	LD	HL,PTR
	INC	(HL)
	LD	A,(HL)
	CP	MAXROCK
	JP	NZ,INLP
	RET
SLAM	LD	HL,XQ
	INC	(HL)
	INC	HL
	INC	(HL)
	LD	A,(YP)
	AND	63
	LD	B,A
	LD	A,(YQ)
	AND	63
	CP	B
	RET	C
	LD	A,(YP)
	RRC
	RRC
	RRC
	AND	7
	LD	B,A
	LD	A,(YQ)
	RRC
	RRC
	RRC
	AND	7
	CP	B
	JP	NZ,NOTSAM
	LD	A,(YP)
	AND	7
	CALL	SETDE
	LD	HL,REM
	ADD	HL,DE
	LD	A,(HL)
	LD	C,A
	LD	A,(YQ)
	AND	7
	CALL	SETDE
	LD	HL,REM
	ADD	HL,DE
	LD	A,(HL)
	CPL
	AND	C
	LD	C,A
	LD	A,B
	ADD	237
	LD	H,A
	LD	A,(XP)
	LD	L,A
	LD	A,(XQ)
	LD	E,A
BOXLOOP	LD	A,(HL)
	OR	C	*
	LD	(HL),A
	INC	L
	LD	A,L
	CP	E
	JP	NZ,BOXLOOP
	RET
NOTSAM	LD	C,A
	LD	A,(YP)
	AND	7
	CALL	SETDE
	LD	HL,REM
	ADD	HL,DE
	LD	A,(HL)
	LD	(TOP),A
	LD	A,(YQ)
	AND	7
	CALL	SETDE
	LD	HL,REM
	ADD	HL,DE
	LD	A,(HL)
	CPL
	LD	(BOT),A
	LD	A,(XP)
	LD	L,A
BEGIN	LD	A,B
	ADD	237
	LD	H,A
	LD	A,(TOP)
	OR	(HL)	*
	LD	(HL),A
	LD	A,C
	SUB	B
	LD	D,A
MIDLP	DEC	D
	JP	Z,DOBOT
	INC	H
	LD	A,(HL)
	OR	255	*
	LD	(HL),A
	JP	MIDLP
DOBOT	INC	H
	LD	A,(BOT)
	OR	(HL)	*
	LD	(HL),A
	INC	L
	LD	A,(XQ)
	CP	L
	JP	NZ,BEGIN
	RET
SETDE	LD	E,A
	LD	D,0
	RET
RND1	CALL	RND
	AND	7
	SUB	3
	JP	Z,RND1
	RET
RND	PUSH	HL
	ADC	(HL)
	LD	HL,RR
	ADC	(HL)
	LD	(HL),A
	INC	HL
	ADC	(HL)
	LD	(HL),A
	INC	HL
	ADC	(HL)
	LD	(HL),A
	POP	HL
	RET
RR	DS	3
TOP	DS	1
BOT	DS	1
XP	DS	1
YP	DS	1
XQ	DS	1
YQ	DS	1
REM	DFB	255,254,252,248
	DFB	240,224,192,128
PTR	DS	1
OFF	DS	1
XS	DS	MAXROCK
XM	DS	MAXROCK
YS	DS	MAXROCK
YM	DS	MAXROCK
SZ	DS	MAXROCK
DUM	DS	0
	!
	LD	HL,OFF
	INC	(HL)
