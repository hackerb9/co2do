	;; Given an address to copy to and the varptr of a BASIC
	;; string, remove the ! escapes by replacing with the next
	;; character minus 128.
	;;
	;; Destination address is sent from BASIC in HL by calling SETUP. 
	;; The varptr of the string is in HL by calling MAIN.
	;; MAIN gets the destination addresss from where SETUP stashed it.

	CPU 8085

	ORG 0
SETUP:	
	SHLD DEST		; Save HL in DESt as destination address. 
	RET

DEST:	DW 0

MAIN:	
	;; HL is VARPTR(P$) where P$ is bang-encoded.
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
	MOV M, A		; Copy the byte from *HL to *DE. 
	XCHG
	INX H
	INX D
	INR C
	DCR B
	JNZ LOOP
END:	
	POP H
	MOV M, C		; Write new length to BASIC string 
	
	RET
