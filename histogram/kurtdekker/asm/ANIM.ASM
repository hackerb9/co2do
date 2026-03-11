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
MAXAL	=	20
	ORG	60000
	CALL	INIT
MAIN	CALL	ALIENS
	CALL	62750
	JP	MAIN
ALIENS	LD	A,(ALPTR)
	INC	A
	CP	MAXAL
	JP	NZ,NORESET
	LD	A,0
NORESET	LD	(ALPTR),A
	LD	E,A
	LD	D,0
	LD	HL,XS
	ADD	HL,DE
	LD	A,(HL)
	LD	(XPOS),A
	LD	HL,YS
	ADD	HL,DE
	LD	A,(HL)
	LD	(YPOS),A
	LD	A,0
	LD	(ONOROFF),A
	LD	HL,SH
	ADD	HL,DE
	LD	A,(HL)
	LD	(SHNUM),A
	CALL	PLOT
	LD	HL,XM
	ADD	HL,DE
	LD	A,(HL)
	LD	HL,XS
	ADD	HL,DE
	ADD	(HL)
	LD	(HL),A
	LD	HL,YM
	ADD	HL,DE
	LD	A,(HL)
	LD	HL,YS
	ADD	HL,DE
	ADD	(HL)
	LD	(HL),A
PLOT	CALL	CALC
	LD	(ROT),A
	LD	(DEST),HL
	LD	A,(SHNUM)
	AND	31
	RLCA
	RLCA
	RLCA
	LD	E,A
	LD	D,0
	LD	HL,SHAPES
	ADD	HL,DE
	LD	(SRCE),HL
	LD	B,8
ROTLP	LD	HL,(SRCE)
	INC	HL
	LD	(SRCE),HL
	DEC	HL
	LD	L,(HL)
	LD	H,0
	LD	A,(ROT)
	LD	C,A
ROTLOOP	LD	A,C
	OR	A
	JP	Z,NOROTS
	ADD	HL,HL
	DEC	C
	JP	ROTLOOP
NOROTS	EX	HL,DE
	LD	A,(ONOROFF)
	OR	A
	JP	Z,RESET
	LD	HL,(DEST)
	LD	A,E
	OR	(HL)
	LD	(HL),A
	INC	H
	LD	A,H
	CP	245
	JP	Z,ENDIT
	LD	A,D
	OR	(HL)
	LD	(HL),A
	JP	ENDIT
RESET	LD	HL,(DEST)
	LD	A,E
	XOR	255
	AND	(HL)
	LD	(HL),A
	INC	H
	LD	A,H
	CP	245
	JP	Z,ENDIT
	LD	A,D
	XOR	255
	AND	(HL)
	LD	(HL),A
ENDIT	LD	HL,(DEST)
	INC	HL
	LD	(DEST),HL
	DEC	B
	JP	NZ,ROTLP
	RET
CALC	LD	A,(YPOS)
	RRA
	RRA
	RRA
	AND	7
	ADD	237
	LD	H,A
	LD	A,(XPOS)
	LD	L,A
	LD	A,(YPOS)
	AND	7
	RET
SRCE	DS	2
DEST	DS	2
ROT	DS	1
ALPTR	DS	1
CNTR	DS	1
XS	DS	MAXAL
YS	DS	MAXAL
XM	DS	MAXAL
YM	DS	MAXAL
SHAPES	DFB	255,129,129,129,129,129
	DFB	129,255

XPOS	DS	1
YPOS	DS	1
SHNUM	DS	1
ONOROFF	DS	1
