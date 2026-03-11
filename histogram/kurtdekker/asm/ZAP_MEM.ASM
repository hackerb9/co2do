
adslkfj aslkfd jasdflk adsflkafla df ERRORS TO MAKE THIS DIFFICULT TO COMPILE


hey look, this tears through your entire M100 memory, zeroing everything.

Don't even COMPILE this program if you don't need to!  I used it for testing
in order to figure out what memory the ROMs modified...

Kurt





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
; PROGRAM:	ZAP.ASM
; AUTHOR:	KURT W. DEKKER
; DATE:		08/16/90 THURS
; MACHINE:	MODEL 100
;
; PURPOSE:	FRIES THE ENTIRE CONTENTS OF RAM FROM 32768 TO THE BASE OF THE
;		PROGRAM, AND UP THROUGH THE SYSTEM RAM, WITH THE INTERRUPTS
;		DISABLED.
;

	ORG	62750
	LD	HL,MSG
	CALL	10161
SURE	CALL	29250
	OR	A
	JP	Z,SURE
	CP	89		; Y
	JP	Z,FRY
	CP	121		; y
	JP	Z,FRY
	JP	0	; DON'T FRY IT
FRY	NOP

	LD	HL,32768
	LD	DE,32769
	LD	BC,29980	; MEMORY UP TO THIS PROGRAM
	XOR	A
	LD	(HL),A
	CALL	27611		; LDIR

	LD	HL,ENDPROG
	LD	DE,ENDPROG
	INC	DE
	LD	BC,10000	; ALL REMAINING MEMORY, AND THEN SOME
	XOR	A
	LD	(HL),A
	DI			; MAKE SURE SYSTEM TIMER DOESN'T HAPPEN
	CALL	27611
	JP	0		; RESTART!

ENDPROG	NOP

MSG	DM	THIS WILL DESTROY MEMORY
	DFB	13,10,10
	DM	ARE YOU SURE (Y/N)?
	DFB	0
