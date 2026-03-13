	;; Given a destination address and the varptr of a BASIC
	;; string, copy the source string to the destination,
	;; processing !-escapes by replacing each '!' with the
	;; subsequent character with the high-bit flipped.

	;; Calling is a two step process. First, the destination
	;; address is sent from BASIC in HL by calling DCINIT.
	;; Second, MAIN (= DCINIT+6) is called with the varptr of
	;; the source string in HL.

	;; The call to DCINIT also specifies a number in register A
	;; from 0 to 255 to be subtracted from every byte. This allows
	;; the coding to be more efficient by rotating the character
	;; set. 

	;; Upon return, the length of the source string is modified to
	;; reflect the actual number of characters written to the
	;; destination address. The source string data is NOT changed.

	;; Example usage from BASIC:
	;;      10 DC=(DCINIT address after relocation)
	;; 	15 A=(rotation offset or 0)
	;;      20 Q=(destination buffer address) 
	;; 	30 READ P$: IF P$="EOD" THEN END
	;;  	40 CALL DC, A, Q
	;; 	50 CALL DC+6, 0, VARPTR(P$)
	;; 	60 Q=Q+LEN(P$)
	;; 	70 GOTO 30
	;; 
	;; When appending multiple strings to the same buffer, the
	;; destination address does not need to be updated each time.
	;; The following is equivalent to the above code:

	;;      10 DC=(DCINIT address after relocation)
	;; 	15 A=(rotation offset or 0)
	;;  	20 CALL DC, A, (destination buffer address) 
	;; 	30 READ P$: IF P$="EOD" THEN END
	;; 	40 CALL DC+6, 0, VARPTR(P$)
	;; 	50 GOTO 30

	CPU 8085		; Build with asmx -w -e -l -b0 decode.asm

	ORG 0			; The BASIC loader relocates this routine.
DCINIT:	
	SHLD DEST		; Save HL in DEST as destination address. 
	RET

DEST:	DW 0

MAIN:	
	;; A is Rotation offset subtracted from each character
	STA ROT

	;; HL starts as VARPTR(P$) where P$ is bang-encoded.
	PUSH H
	MOV B, M		; B is length of input string
	MVI C, 0		; C will be resulting length
	INX H
	MOV E, M		; Load actual address of string into DE
	INX H
	MOV D, M
	LHLD DEST		; Restore HL from saved DEST
	XCHG			; Now HL is P$'s actual address
				; and DE is address of destination
	MOV A, B
	ANA A
	JZ END			; Zero-length string?
LOOP:	
	MOV A, M		; Get next byte from source (*HL)
	CPI '!'
	JNZ WRITE		; If not '!' just copy the character.
	DCR B
	JZ END			; Ignore escape char with no following char. 
	INX H			; Char is '!' so get next char in A
	MOV A, M
	XRI 128			; Decode character by flipping bit 7
WRITE:	
	XCHG
	DB D6h			; D6 is SUI instruction
ROT:	DB 136			; This value is subtracted from char
	MOV M, A		; Copy the byte from *HL to *DE. 
	XCHG
	INX H
	INX D
	INR C
	DCR B
	JNZ LOOP
END:	
	XCHG			; Save DE in DEST so next call can skip DCINIT 
	SHLD DEST
	XCHG			; Not needed, just being overly fastidious
	POP H
	MOV M, C		; Write new length to BASIC string 
	
	RET
