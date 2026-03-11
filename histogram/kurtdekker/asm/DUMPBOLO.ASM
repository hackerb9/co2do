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
	ORG	62750
	DI
	LD	HL,60672
	IN	178
	AND	252
	OUT	178
	LD	A,0
	LD	(WHICH),A
LOOP1	LD	A,3
	OUT	177
	LD	A,(WHICH)
	OUT	254
	LD	A,1
	OUT	177
LOOP	NOP
	NOP
	NOP
	LD	A,(HL)
	OUT	255
	INC	HL
	LD	A,L
	CP	50
	JP	NZ,NO2
	LD	A,2
	OUT	177
NO2	LD	A,L
	CP	64
	JP	NZ,LOOP
	LD	L,0
	INC	H
	LD	A,(WHICH)
	ADD	64
	LD	(WHICH),A
	JP	NZ,LOOP1
XLOOP1	LD	A,96
	OUT	177
	LD	A,(WHICH)
	OUT	254
	LD	A,32
	OUT	177
XLOOP	NOP
	NOP
	NOP
	LD	A,(HL)
	OUT	255
	INC	HL
	LD	A,L
	CP	50
	JP	NZ,XNO2
	LD	A,64
	OUT	177
XNO2	LD	A,L
	CP	64
	JP	NZ,XLOOP
	LD	L,0
	INC	H
	LD	A,(WHICH)
	ADD	64
	LD	(WHICH),A
	JP	NZ,XLOOP1
	EI
	RET
WHICH	DS	1
