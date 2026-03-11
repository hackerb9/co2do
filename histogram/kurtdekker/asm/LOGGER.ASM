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

;**********************************************************************************************************************
;
; Author:	Kurt W. Dekker
; Started:	Who in the hell knows when!  Punahou sometime!
; Updated:	09/16/93
; Filename:	LOGGER.ASM
;
;**********************************************************************************************************************
;
; 09/16/93:	Updating this game so that it listens to the CapsLock key to
;		see if sound is On/Off.  This makes it an infinitely more
;		useful game, rather than having to make a separate executable,
;		like LOGGERQ, which is how I've done it so far.
;
;**********************************************************************************************************************


MINEMV	=	2
WALL1	=	45
WALL2	=	205
UPD	=	62750
INCRATE	=	4
YOULEN	=	8
XMV	=	3
YMV	=	2
LOGLEN	=	14

	ORG	57500

NEWGAME	CALL	ONETIM

NEWWAV	CALL	INIT

	CALL	STAGE

MAIN	XOR	A
	LD	(65450),A
	LD	HL,60698
	LD	DE,60906
	LD	B,8
	LD	A,170
IOIO	LD	(HL),A
	LD	(DE),A
	INC	H
	INC	D
	DEC	B
	JP	NZ,IOIO
	CALL	INTA
	CALL	TIME
	CALL	KEYIN
	CALL	YOU
	CALL	UPD
	JP	MAIN

WALL	LD	A,3
	LD	(SHNUM),A
	CALL	RND
	AND	32
	JP	Z,DOWN
	LD	B,MINEMV
	JP	UP
DOWN	XOR	A
	SUB	MINEMV
	LD	B,A
UP	LD	A,(WALLPOS)
	LD	(OLDPOS),A
	ADD	B
	CP	56
	JP	NC,DOWAMV
	LD	(WALLPOS),A
DOWAMV	LD	A,(OLDPOS)
	LD	(YP),A
	XOR	A
	LD	(ONOFF),A
	LD	A,WALL1
	LD	(XP),A
	CALL	PLOT
	LD	A,56
	LD	HL,YP
	SUB	(HL)
	LD	(YP),A
	LD	A,WALL2
	LD	(XP),A
	CALL	PLOT
DRDNTMV	LD	A,(WALLPOS)
	LD	(YP),A
	LD	A,1
	LD	(ONOFF),A
	LD	A,WALL1
	LD	(XP),A
	CALL	PLOT
	LD	A,56
	LD	HL,YP
	SUB	(HL)
	LD	(YP),A
	LD	A,WALL2
	LD	(XP),A
	CALL	PLOT
	RET

INTA	LD	A,(INT1)
	OR	A
	RET	Z
	DEC	A
	LD	(INT1),A
	INC	A
	ADD	A
	ADD	A
	ADD	4
	LD	C,A
	LD	B,20
	JP	BEEP

TIME	LD	A,(YET1)
	DEC	A
	LD	(YET1),A
	JP	NZ,DOTIME
	LD	A,25
	LD	(YET1),A
	LD	A,(CARGO)
	OR	A
	JP	Z,DOTIME
MM	DEC	A
	PUSH	AF
	AND	3
	ADD	A
	ADD	A
	ADD	3
	LD	(XP),A
	POP	AF
	PUSH	AF
	AND	28
	ADD	3
	LD	(YP),A
	LD	A,2
	LD	(SHNUM),A
	LD	A,1
	LD	(ONOFF),A
	CALL	PLOT
	POP	AF
	OR	A
	JP	NZ,MM
DOTIME	LD	HL,62474
	LD	A,(LEFT)
	OR	A
	JP	Z,WAVDUN
	LD	B,A
LDIR3	LD	A,128
	OR	(HL)
	LD	(HL),A
	INC	L
	DEC	B
	JP	NZ,LDIR3
	LD	(HL),0
	LD	HL,YET
	DEC	(HL)
	JP	NZ,NODEC
	LD	B,20
	LD	C,20
	CALL	BEEP
	LD	HL,LEFT
	DEC	(HL)
	LD	A,(DECSPD)
	LD	(YET),A
NODEC	RET

BEEP	LD	A,(SNDONOFF)
	OR	A
	RET	Z
	LD	A,C
BEEP1	DEC	A
	JP	NZ,BEEP1
	CALL	30326
	DEC	B
	JP	NZ,BEEP
	RET

SCOREIT	LD	A,12
	LD	(INT1),A
	LD	A,(WAVE)
	LD	E,A
	LD	D,0
	LD	HL,(SCORE)
	ADD	HL,DE
	LD	(SCORE),HL
	RET

WAVDUN	POP	HL
	LD	A,(CARGO)
	LD	B,A
	INC	B
BONUSL	DEC	B
	JP	Z,NOBON
	CALL	SCOREIT
	JP	BONUSL
NOBON	LD	A,(YET2)
	INC	A
	LD	(YET2),A
	AND	3
	JP	NZ,NODUMP
	XOR	A
	LD	(CARGO),A
NODUMP	LD	A,(DECSPD)
	INC	A
	LD	(DECSPD),A
	LD	A,(WAVE)
	INC	A
	LD	(WAVE),A
	JP	NEWWAV

YOU	LD	HL,(X1)
	LD	(XP),HL
	XOR	A
	LD	(ONOFF),A
	LD	A,(USHAPE)
	LD	(SHNUM),A
	CALL	PLOT

	CALL	LOGS
	CALL	WALL

	LD	A,(KEY1)
	AND	1
	JP	Z,NOTUP
	LD	A,(Y1)
	SUB	YMV
	CP	254
	JP	Z,NOTUP
	LD	(Y1),A
NOTUP	LD	A,(KEY2)
	AND	1
	JP	Z,NOTDN
	LD	A,(Y1)
	ADD	YMV
	CP	60
	JP	NC,NOTDN
	LD	(Y1),A
NOTDN	LD	A,(KEY1)
	AND	128
	JP	Z,NOTL
	LD	A,(X1)
	SUB	XMV
	CP	25
	JP	NC,YESL
	LD	A,(USHAPE)
	OR	A
	JP	Z,NOTL
	XOR	A
	LD	(USHAPE),A
	LD	HL,CARGO
	INC	(HL)
	CALL	SCOREIT
	CALL	SCOREIT
	JP	NOTL
YESL	LD	(X1),A
NOTL	LD	A,(KEY2)
	AND	128
	JP	Z,NOTR
	LD	A,(X1)
	ADD	XMV
	CP	230
	JP	C,YESR
	LD	A,(USHAPE)
	OR	A
	JP	NZ,NOTR
	LD	A,1
	LD	(USHAPE),A
	CALL	SCOREIT
	JP	NOTR
YESR	LD	(X1),A
NOTR	LD	HL,(X1)
	LD	(XP),HL
	LD	A,1
	LD	(ONOFF),A
	LD	A,(USHAPE)
	LD	(SHNUM),A
	CALL	PLOT
	LD	A,(COLLIS)
	OR	A
	RET	Z
	POP	HL
	CALL	UPD
	LD	E,50
BHRW	LD	C,E
	LD	B,30
	CALL	BEEP
	LD	A,E
	ADD	10
	LD	E,A
	CP	200
	JP	NZ,BHRW
	LD	A,(MAXX)
	SUB	INCRATE
	LD	(MAXX),A
	LD	A,(SHIPS)
	DEC	A
	LD	(SHIPS),A
	JP	NZ,NEWWAV
	CALL	VITAL
	LD	HL,MSG2
	CALL	10161
WAIT	CALL	29250
	CP	13
	JP	NZ,WAIT
	JP	NEWGAME

;**********************************************************************************************************************
;
; 09/16/93: modified to read the CapsLock key and turn the sound on or off.
;
;**********************************************************************************************************************
KEYIN	DI

	IN	178
	AND	254
	OUT	178
	LD	A,255
	OUT	177
	IN	225
	CPL
	LD	B,A
	AND	16
	JP	NZ,KEYIN	; causes a pause

	LD	A,B
	AND	32
	LD	(SNDONOFF),A

	IN	178
	OR	1
	OUT	178
	LD	A,191
	OUT	177
	IN	225
	CPL
	LD	(KEYSP),A

;	AND	1
;	JP	Z,NOPOZ
;	XOR	A
;	LD	(65450),A
;POZ:
;	CALL	29250
;	CP	13
;	JP	NZ,POZ
;NOPOZ:

	LD	A,254
	OUT	177
	IN	225
	CPL
	LD	(KEY2),A
	LD	A,253
	OUT	177
	IN	225
	CPL
	LD	(KEY1),A
	EI
	RET

LOGS	XOR	A
	LD	(PTR),A
LOGLP	LD	A,(PTR)
	LD	E,A
	LD	D,0
	LD	HL,LOGPOS
	ADD	HL,DE
	LD	L,(HL)
	LD	A,(PTR)
	AND	7
	ADD	237
	LD	H,A
	LD	DE,LOGSH
	LD	B,LOGLEN
ANDLDIR	LD	A,(DE)
	CPL
	AND	(HL)
	LD	(HL),A
	INC	L
	INC	DE
	DEC	B
	JP	NZ,ANDLDIR
	LD	A,(PTR)
	LD	E,A
	LD	D,0
	LD	HL,LOGMV
	ADD	HL,DE
	LD	A,(HL)
	LD	HL,LOGPOS
	ADD	HL,DE
	ADD	(HL)
	CP	23
	JP	C,NOTOK
	CP	228
	JP	C,OKAY
NOTOK	PUSH	HL
	LD	HL,LOGMV
	ADD	HL,DE
	XOR	A
	SUB	(HL)
	LD	(HL),A
	POP	HL
	LD	A,(HL)
OKAY	LD	(HL),A
	LD	L,A
	LD	A,(PTR)
	AND	7
	ADD	237
	LD	H,A
	LD	B,LOGLEN
	LD	DE,LOGSH
ORLDIR	LD	A,(DE)
	OR	(HL)
	LD	(HL),A
	INC	L
	INC	DE
	DEC	B
	JP	NZ,ORLDIR

	LD	A,(PTR)
	INC	A
	LD	(PTR),A
	LD	HL,MAX
	CP	(HL)
	JP	NZ,LOGLP
	RET

INAL	XOR	A
	LD	(INT1),A
	LD	A,1
	LD	(YET),A
	LD	(YET1),A
	LD	(YET3),A
	LD	A,(MAXX)
	ADD	INCRATE
	LD	(MAXX),A
	LD	(MAX),A
	XOR	A
	LD	(PTR),A
INALLP	LD	A,(PTR)
	LD	E,A
	LD	D,0
	LD	HL,LOGPOS
	ADD	HL,DE
	CALL	RND
	AND	63
	LD	B,A
	CALL	RND
	AND	32
	LD	A,B
	JP	Z,NOINC
	ADD	135
NOINC	ADD	25
	LD	(HL),A
AGEN	CALL	RND
	AND	3
	JP	Z,AGEN
	LD	B,A
	CALL	RND
	AND	64
	JP	Z,NOREV
	XOR	A
	SUB	B
	LD	B,A
NOREV	LD	A,B
	LD	HL,LOGMV
	ADD	HL,DE
	LD	(HL),A
	LD	A,(PTR)
	INC	A
	LD	(PTR),A
	LD	HL,MAX
	CP	(HL)
	JP	NZ,INALLP
	RET

INIT	LD	A,140
	LD	(LEFT),A
	XOR	A
	LD	(USHAPE),A
	LD	A,28
	LD	(WALLPOS),A
	LD	(Y1),A
	LD	A,120
	LD	(X1),A
	CALL	INAL
	CALL	CLS
	RET

ONETIM	XOR	A
	LD	(CARGO),A
	LD	(YET2),A
	LD	A,4
	LD	(SHIPS),A
	LD	A,4
	LD	(MAXX),A
	LD	A,4
	LD	(DECSPD),A
	LD	A,1
	LD	(WAVE),A
	LD	HL,0
	LD	(SCORE),HL
	RET

CLS	LD	HL,60672
	LD	DE,60673
	LD	BC,2047
	LD	(HL),0
	JP	27611

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

VITAL	LD	HL,MSG1
	CALL	10161
	LD	HL,(SCORE)
	CALL	14804
	LD	A,48
	RST	32
	LD	A,13
	RST	32
	LD	A,10
	RST	32
	LD	A,(WAVE)
	LD	B,A
WAVLP	DEC	B
	JP	Z,DUNWVL
	LD	A,133
	RST	32
	JP	WAVLP
DUNWVL	LD	HL,MSG3
	CALL	10161
	LD	A,(SHIPS)
	LD	L,A
	LD	H,0
	CALL	14804
	RET

STAGE	CALL	VITAL
	CALL	DELAY
	XOR	A
	LD	(KEY1),A
	LD	(KEY2),A
	CALL	CLS
	CALL	LOGS
	CALL	YOU
	CALL	62750
	CALL	DELAY
	RET

DELAY:
	mov	hl,PAKMSG
	call	10161
DELAY1:
	call	29250
	cmp	0
	jp	z,DELAY1
	ret

;DELAY	LD	B,4
;DEL2	LD	HL,0
;DEL1	DEC	HL
;	LD	A,H
;	OR	L
;	JP	NZ,DEL1
;	DEC	B
;	JP	NZ,DEL2
;	RET

MSG3	DFB	13,10
	DM	SHIPS:
	DFB	0

MSG2	DFB	13,10
	DM	GAME OVER!!  (PRESS <ENTER>)
	DFB	0

PAKMSG	DFB	13,10
	dm	Press Any Key...
	dfb	0

MSG1	DFB	12
	DM	LOGGER, BY KURT DEKKER (C) 1985
	DFB	13,10,10
	DM	SCORE:
	DFB	0

SHTABS	DFB	15,9,9,9,9,15,0,0

	DFB	15,15,15,15,15,15,0,0

	DFB	7,5,7,0,0,0,0,0

	DFB	255,129,129,129
	DFB	129,129,129,255

	DFB	24,24,24,255
	DFB	255,24,24,24

LOGSH	DFB	28,34,73,99,93,65
	DFB	65,65
	DFB	65,65,65,65,34,28

RR	DS	3
PTR	DS	1
MAXX	DS	1
MAX	DS	1

LOGPOS	DS	48
LOGMV	DS	48

KEY1	DS	1
KEY2	DS	1
KEYSP	DS	1

X1	DS	1
Y1	DS	1
USHAPE	DS	1

XP	DS	1
YP	DS	1
COLLIS	DS	1
SHNUM	DS	1
ONOFF	DS	1
SCPTR	DS	2
SHPTR	DS	2

SCORE	DS	2
LEFT	DS	1
YET	DS	1
YET1	DS	1
YET2	DS	1
YET3	DS	1
WALLPOS	DS	1
OLDPOS	DS	1
DECSPD	DS	1
WAVE	DS	1
SHIPS	DS	1

SNDONOFF DS	1

CARGO	DS	1

INT1	DS	1
