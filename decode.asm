	;; Given an address of a BASIC string in HL, remove the !
	;; escapes by replacing with the next character minus 128.
	;; Update the string length.

	CPU 8085

	ORG 0
	PUSH H
	MOV B, M		; B is length of input string
	MVI C, 0		; C is resulting length
	INX H
	MOV E, M		; DE is actual address of string
	INX H
	MOV D, M
	
	MOV H, D		; HL = DL
	MOV L, E

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
