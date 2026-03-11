
11:18 AM 7/3/2004

Kurt W Dekker's open-sourced TRS-80 Model 100 code.

Please see the enclosed Gnu Public License (GPL) for details.

email:  m100@plbm.com
web:  www.plbm.com (or http://www.plbm.com/m100)

Open-sourced on July 3, 2004... at least the first installment!
I'm going to cull through this mass of code and data and bit
by bit open it up. I have to separate personal documents from
the code as I go through it. Please bear with me.

Do whatever you want with this code but don't blame me for
anything that results from these doings.  A lot of this stuff
is complete, but then again a lot of it isn't complete either.

Caveat Hackor!

Kurt Dekker

PS - I was inspired by the www.bitchin100.com site - thanks John!

****************************************************************

General Notes:

Your first stop should be the util\ subdirectory. Download the
FTU.BAS program to your M100 and that will be your friend as
you send .DEC files down to the M100 for running machine code.

**** ALL my games require that you FIRST downloaded the
	DUMP.DEC file to the M100!!!

****************************************************************

Game notes:

Almost all games are controlled with A/Z for up/down and K/L
for left right, with SPACE as fire, and ENTER as secondary fire.

Generally, DUMP.CO sits in high mem and provides screen update
service for which ever game you're running at that moment. See
the source of DUMP.CO for where it resides, what block of memory
it updates to the screen, etc. It never changes where it is...

****************************************************************

Other blather about this code:

This code has been written over the past two decades, starting
in 1984 with the purchase of my first TRS-80 Model 100 laptop.

I named my first laptop Vanessa, and thus when I wrote the
Virtual Vanessa emulator, that's what I named it.  See the VV\
subdirectory for the current Virtual Vanessa distro.

****************************************************************

A word about non-obvious filenames:

*.A85 - 8085 assembly source code (use the A85.EXE cross-assembler)
*.ASM - assembly source code, might be either 8085 or 8086
*.DEC - my checksum-equipped "binary" text file - contains a
	program "image" for uploading with the FTU.BAS program.

****************************************************************

Now some descriptions of files:

ASM40.ASM - the 4.0 version of my assembler. I _think_ this is
	the latest and greatest, but I could be wrong...
ASMASM.ASM - my assembly language 8085 assembler for Model 100
ASMBASIC.BAS - the first assembler I wrote, in TRS-80 Model 100
	BASIC. I used it to assemble my assembly-language
	assembler, which was at least 100 times faster. :)
DUMP.ASM - the screen refresh utility that ALL my games use.
DUMP2.ASM - version with 2 extra NOP codes to slow it down for
	certain Model 100s with slower display hardware.
DUMPBOLO.ASM - special smaller-screen dumper written for BOLO.ASM
