# When decode.asm is modified, assemble it and embed the machine
# language into co2do using embedasm.

co2do: decode.asm.lst embedasm
	./embedasm $@ $<

%.asm.lst: %.asm
	asmx -w -e -l -b0 $< 2>&1 | sed '/00000 Total Error/,// d'

