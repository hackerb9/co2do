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

;*****************************************************************************
;
; Author:	Kurt W. Dekker
; Started:	07/14/96 (actually coding on Vanessa herself!)
; Updated:	07/14/96
; Filename:	DOCSZ.A85
;
; Description:	a utility for the model 100 to show how big each of
;		the .DO files are.  scans all files in the directory now.
;

	org	62750

	; clear the screen
	mov	a,12
	rst	32

	mov	a,10
	rst	32

	; assume the value of total will be zero initially

	; start scanning the directory structure
	mov	hl,63842
	mov	(curdir),hl

	; maximum number of directory entries
	mov	a,27
	mov	(count),a

	; column number
	mov	a,0
	mov	(column),a

mainloop:
	mov	hl,(curdir)
	mov	a,(hl)
	cp	192
	jp	nz,notdoc

	inc	hl
	mov	e,(hl)
	inc	hl
	mov	d,(hl)
	inc	hl

	mov	c,6
name1:
	mov	a,(hl)
	inc	hl
	rst	32
	dec	c
	jp	nz,name1

;	mov	a,'.'
;	rst	32

;	mov	c,2
;name2:
;	mov	a,(hl)
;	inc	hl
;	rst	32
;	dec	c
;	jp	nz,name2

	mov	a,':'
	rst	32

	; save base address of this file
	push	de

	; display address of this file
;	mov	a,'('
;	rst	32
;	push	de
;	pop	hl
;	call	14804
;	mov	a,')'
;	rst	32

	; restore base address of file
	pop	hl

	; now we go scan for the file's size
	mov	de,65535	; -1
sizeloop:
	mov	a,(hl)
	inc	hl
	inc	de
	cmp	26
	jp	nz,sizeloop

	; throw this up onto the stack...
	push	de

	; figure if we need leading spaces or not
	push	de
	pop	hl

	mov	de,10000
	rst	24
	jp	nc,nospc1
	mov	a,32
	rst	32
nospc1:
	mov	de,1000
	rst	24
	jp	nc,nospc2
	mov	a,32
	rst	32
nospc2:
	mov	de,100
	rst	24
	jp	nc,nospc3
	mov	a,32
	rst	32
nospc3:
	mov	de,10
	rst	24
	jp	nc,nospc4
	mov	a,32
	rst	32
nospc4:

	; add this size to the total
	pop	de
	push	de
	mov	hl,(total)
	add	hl,de
	mov	(total),hl

	; display the size we calculated
	pop	hl
	call	14804

	mov	hl,column
	inc	(hl)
	mov	a,(hl)
	cp	3
	jp	nz,nonewline

	; fresh line yet?
	mov	(hl),0

; we actually don't need to do this cr/lf because we wrote exactly 40 chars!
;	mov	a,13
;	rst	32
;	mov	a,10
;	rst	32
	jp	nogap

nonewline:
	mov	a,234		; together they make a block!
	rst	32
	dec	a
	rst	32

nogap:

notdoc:
	; move onto the next directory entry
	mov	hl,(curdir)
	mov	de,11
	add	hl,de
	mov	(curdir),hl

	mov	hl,count
	dec	(hl)
	jp	nz,mainloop

	mov	a,(column)
	or	a
	jp	z,nocrlf
	mov	a,13
	rst	32
	mov	a,10
	rst	32
nocrlf:
	mov	hl,totalmsg
	call	10161
	mov	hl,(total)
	call	14804

	mov	a,13
	rst	32
	mov	a,10
	rst	32

keywait:
	call	4811	; get a$

	rst	0

totalmsg:
	dm	Total:
	dfb	0
total	ds	2
count	ds	1
curdir	ds	2
column	ds	1
