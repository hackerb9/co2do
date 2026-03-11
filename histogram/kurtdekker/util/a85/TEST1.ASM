	org	58000

	push	hl
	push	de
	push	bc
	push	af
	ei
	scf
	pop	af
	pop	bc
	pop	de
	pop	hl
	ret	nz
