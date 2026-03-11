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
	ORG	WHEREVER
	DI
	LD	HL,60672
	LD	(CURR2),HL
	LD	HL,1
	LD	(ONESEV),HL
LP1	LD	HL,(ONESEV)
	LD	A,L
	OUT	177
	IN	178
	AND	252
	OR	H
	OUT	178
	LD	A,0
	LD	(WHICH),A
LP2	LD	A,(WHICH)
	OUT	254
	RLC
	RLC
	LD	C,50
	LD	HL,(CURR2)
	LD	D,A
	LD	E,0
	ADD	HL,DE
	LD	A,L
	CP	199
	JP	C,FIFTY
	LD	C,40
FIFTY	LD	A,(HL)
	NOP
	NOP
	OUT	255
	INC	L
	DEC	C
	JP	NZ,FIFTY
	LD	A,(WHICH)
	ADD	64
	LD	(WHICH),A
	JP	NZ,LP2
	LD	HL,(ONESEV)
	ADD	HL,HL
	LD	(ONESEV),HL
	LD	A,H
	CP	4
	JP	Z,OVER
	LD	A,L
	CP	32
	JP	NZ,NOHLUP
	LD	HL,61696
	LD	(CURR2),HL
	JP	GO4IT
NOHLUP	LD	DE,50
	LD	HL,(CURR2)
	ADD	HL,DE
	LD	(CURR2),HL
GO4IT	JP	LP1
OVER	RET
WHICH	DS	1
CURR2	DS	2
ONESEV	DS	2
	!
