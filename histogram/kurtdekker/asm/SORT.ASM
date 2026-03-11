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
; Sort; saved 6/10/87
	ORG	58000
	XOR	A
	LD	(DIR),A
ZZX	LD	HL,M1
ZZZ	CALL	10161
	LD	HL,BUFR
	LD	(HL),32
	PUSH	HL
	POP	DE
	INC	DE
	LD	BC,5
	CALL	27611
	XOR	A
	LD	(LEN),A
	JP	INORD
STRIN	CALL	29250
	OR	A
	JP	Z,STRIN
	CP	16
	JP	NZ,NOORD
	LD	A,(DIR)
	XOR	1
	LD	(DIR),A
INORD	LD	A,(DIR)
	ADD	A
	ADD	A
	ADD	A
	ADD	A
	LD	E,A
	LD	D,0
	LD	HL,MMM
	ADD	HL,DE
	CALL	10161
	LD	A,(LEN)
	LD	B,A
	OR	A
	JP	Z,STRIN
ZZLP	LD	A,67
	CALL	17008
	DEC	B
	JP	NZ,ZZLP
	JP	STRIN

NOORD	CP	32
	LD	B,A
	JP	NZ,NOSPA
	LD	A,(LEN)
	OR	A
	JP	Z,STRIN
	LD	A,B
NOSPA	CP	8
	JP	NZ,NOBS
	LD	A,(LEN)
	OR	A
	JP	Z,STRIN
	DEC	A
	LD	C,A
	LD	B,0
	LD	HL,BUFR
	ADD	HL,BC
	LD	(HL),32
	LD	HL,LEN
	DEC	(HL)
	LD	A,8
	RST	32
	LD	A,32
	RST	32
	LD	A,8
	RST	32
	JP	STRIN
NOBS	CP	13
	JP	Z,CR
	CP	27
	JP	Z,0
	CP	32
	JP	C,STRIN
	CP	128
	JP	NC,STRIN
	CALL	UCASE
	PUSH	AF
	POP	BC
	LD	A,(LEN)
	CP	6
	JP	Z,STRIN
	LD	E,A
	LD	D,0
	LD	HL,BUFR
	ADD	HL,DE
	LD	(HL),B
	LD	A,B
	RST	32
	LD	HL,LEN
	INC	(HL)
	JP	STRIN
CR	LD	A,'Q'
	CALL	17008
	LD	A,(LEN)
	OR	A
	JP	Z,0
	LD	A,13
	RST	32
	LD	A,10
	RST	32
	RST	32
	LD	A,19
	LD	(PTR),A
	LD	HL,63930
	LD	(HOLD),HL
DIRSL	LD	HL,(HOLD)
	LD	A,(HL)
	CP	192
	JP	NZ,NOTTEX
	INC	HL
	LD	A,(HL)
	LD	(LOB),A
	INC	HL
	LD	A,(HL)
	LD	(HIB),A
	INC	HL
	LD	DE,BUFR
	LD	B,6
CPIR	LD	A,(DE)
	CP	(HL)
	JP	NZ,NOTTEX
	INC	HL
	INC	DE
	DEC	B
	JP	NZ,CPIR
	JP	FOUND
NOTTEX	LD	HL,(HOLD)
	LD	DE,11
	ADD	HL,DE
	LD	(HOLD),HL
	LD	HL,PTR
	DEC	(HL)
	JP	NZ,DIRSL
	LD	HL,M2
	CALL	10161
	LD	A,11
	RST	32
	LD	HL,M1
	INC	HL
	JP	ZZZ
PAUSEZ	CALL	29250
	CP	13
	JP	NZ,PAUSEZ
	JP	ZZX
UCASE	CP	97
	RET	C
	CP	123
	RET	NC
	SUB	32
	RET

FOUND	LD	HL,0
	LD	(LINES),HL
	LD	HL,(LOB)
	LD	A,10
	LD	(LAST),A
CHKLP	LD	A,(HL)
	CP	26
	JP	Z,DONE
	CP	10
	JP	NZ,NOT10
	PUSH	HL
	LD	HL,(LINES)
	INC	HL
	LD	(LINES),HL
	POP	HL
NOT10	LD	(LAST),A
	INC	HL
	JP	CHKLP

DONE	LD	A,(LAST)
	CP	10
	JP	Z,FILEOK
	LD	HL,M3
	CALL	10161
	JP	PAUSEZ

FILEOK	LD	HL,(LINES)
	CALL	14804
	LD	HL,M5
	CALL	10161
	LD	HL,(LINES)
	LD	DE,2
	RST	24
	JP	NC,MAIN

SORTED	LD	HL,M4
	CALL	10161
	JP	PAUSEZ

MAIN	LD	HL,0
	LD	(NUM),HL
	XOR	A
	LD	(FLAG),A
	LD	HL,(LOB)
	LD	(HOLD2),HL
LOOP1	LD	HL,(HOLD2)
SRCH1	LD	A,(HL)
	CP	10
	INC	HL
	JP	NZ,SRCH1
	LD	(MIDL),HL
	LD	A,(HL)
	CP	26
	JP	Z,OVERW
SRCH2	LD	A,(HL)
	CP	10
	INC	HL
	JP	NZ,SRCH2
	DEC	HL
	LD	(FINIS),HL
	LD	HL,(MIDL)
	EX	DE,HL
	LD	HL,(HOLD2)
	CALL	COMP
	JP	NC,NOSWAP
	LD	HL,(FINIS)
	EX	DE,HL
	LD	HL,(HOLD2)
	CALL	SWITCH
	LD	HL,(NUM)
	INC	HL
	LD	(NUM),HL
	LD	A,1
	LD	(FLAG),A
NOSWAP	LD	HL,(HOLD2)
NEXT1	LD	A,(HL)
	CP	10
	INC	HL
	JP	NZ,NEXT1
	LD	(HOLD2),HL
	JP	LOOP1
OVERW	LD	HL,(NUM)
	CALL	14804
	LD	A,32
	RST	32
	RST	32
	LD	A,13
	RST	32
	CALL	29250
	CP	27
	JP	Z,ZZX
	LD	A,(FLAG)
	OR	A
	JP	NZ,MAIN
	JP	SORTED

LESS	SCF
	RET

GREAT	XOR	A
	RET

COMP	LD	A,(DIR)
	OR	A
	JP	NZ,DODESC
COMPLP	LD	A,(HL)
	CP	13
	JP	Z,GREAT
	LD	A,(DE)
	CP	13
	JP	Z,LESS
	LD	A,(DE)
	CP	(HL)
	INC	HL
	INC	DE
	JP	Z,COMPLP
	JP	C,LESS
	JP	GREAT

DODESC	LD	A,(DE)
	CP	13
	JP	Z,GREAT
	LD	A,(HL)
	CP	13
	JP	Z,LESS
	LD	A,(DE)
	CP	(HL)
	INC	HL
	INC	DE
	JP	Z,DODESC
	JP	C,GREAT
	JP	LESS

SWITCH	LD	(BEG),HL
	EX	DE,HL
	LD	(END),HL
	EX	DE,HL
	CALL	SWAP
	LD	HL,(BEG)
	INC	HL
LOOK1	LD	A,(HL)
	CP	10
	INC	HL
	JP	NZ,LOOK1
	DEC	HL
	PUSH	HL
	DEC	HL
	EX	DE,HL
	LD	HL,(BEG)
	CALL	SWAP
	LD	HL,(END)
	EX	DE,HL
	POP	HL
	CALL	SWAP
	RET

SWAP	RST	24
	RET	NC
SWAPLP	LD	B,(HL)
	LD	A,(DE)
	LD	(HL),A
	LD	A,B
	LD	(DE),A
	DEC	DE
	INC	HL
	RST	24
	JP	C,SWAPLP
	RET

DIR	DS	1
LOB	DS	1
HIB	DS	1
NUM	DS	2
HOLD	DS	2
PTR	DS	1
LEN	DS	1
BUFR	DS	6
LAST	DS	1
LINES	DS	2
BEG	DS	2
END	DS	2
HOLD2	DS	2
MIDL	DS	2
FINIS	DS	2
FLAG	DS	1

M1	DFB	12
	DM	Sort version 1.0
	DFB	13,10,10
	DM	File:  <      >
	DFB	8,8,8,8,8,8,8,27,'P',0

M2	DFB	13,10,10
	DM	No File
	DFB	0
M3	DFB	13,10,10
	DM	Bad file EOF, must be CR/LF - Press CR
	DFB	0

M4	DFB	13,10,10
	DM	Sorting completed - Press CR
	DFB	0

M5	DM	 elements.
	DFB	13,10,0

MMM	DFB	13,10,10
	DM	(Asc)   
	DFB	27,65,27,65,0
	DFB	13,10,10
	DM	(Desc)  
	DFB	27,65,27,65,0
