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
	ORG	58000
	LD	A,32
	LD	(ZXPO),A
	LD	A,1
	LD	(ZXMV),A
MAIN	CALL	PRTZX
	CALL	62750
	JP	MAIN
SETDE	LD	E,A
	LD	D,0
	RET
PRTZX	LD	A,(ZXMV)
	LD	HL,ZXPO
	ADD	(HL)
	LD	(HL),A
	JP	Z,BNC
	CP	56
	JP	C,NOBNC
BNC	LD	A,(ZXMV)
	CPL
	INC	A
	LD	(ZXMV),A
NOBNC	LD	A,(ZXPO)
	CALL	SETDE
	LD	HL,62592
	ADD	HL,DE
	EX	DE,HL
	LD	A,(ZXMV)
	AND	128
	JP	Z,ZXRT
	LD	HL,ZX2
	JP	PRT
ZXRT	LD	HL,ZX
PRT	LD	B,57
PRTZXLP	LD	A,(HL)
	LD	(DE),A
	INC	E
	INC	HL
	DEC	B
	JP	NZ,PRTZXLP
	RET
ZXPO	DS	1
ZXMV	DS	1
ZX	DFB	255
	DFB	0,198,161,145,137,198,0
	DFB	118,137,137,137,118,0
	DFB	126,129,129,129,126,0
	DFB	0,8,8,8,0,0
	DFB	195,169,153,141,203,0
	DFB	227,149,8,149,227
	DFB	0,17,62,60,124,250,254
	DFB	122,58,60,60,56,120
	DFB	248,248,112,48,32,0,255
ZX2	DFB	255,0,32,48,112,248,248
	DFB	120,56,60,60,58,122
	DFB	254,250,124,60,62,17,0
	DFB	198,161,145,137,198,0
	DFB	118,137,137,137,118,0
	DFB	126,129,129,129,126,0
	DFB	0,8,8,8,0,0
	DFB	195,169,153,141,203,0
	DFB	227,149,8,149,227,0,255
PWAF	DFB	0,0,60,10,2,0,30,32,30
	DFB	0,28,34,20,0,62,8,54
	DFB	0,0
	!
