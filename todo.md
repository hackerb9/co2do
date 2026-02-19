## Todo

* Cleanup the ugly warnmem branch. Should only WARN, not ERR if the
  .DO file will not fit.

* POKEing >= MAXRAM == big disaster! Maybe BASIC program should check
  MAXRAM? NEC PC8201 has no "MAXRAM" but the PC-8300 techref implies
  it is a fixed value: 62336. We can detect a NEC using PEEK(1)==148.
  Is this a good use of bytes?
  
* For speed, investigate using a **small** M/L program to copy the
  data directly to the correct location and printing status to the
  screen with RST 4.
  * Q: Where can that program live? 
	A: John Hogerhuis suggests as a string in the BASIC program. 
  * Would have to parse it in BASIC to make it runnable. (Slash
    escapes, addr relocate). How many bytes does that take?
  * VARPTR is possible on NEC but not builtin. Again, how many bytes?

## Misfeature details

* Currently the BASIC loader is way too slow due to string parsing and
  printing to the screen. VARPTR might help with the former, but I
  believe M/L is needed to improve printing speed.
* Despite having better compression than the usual HEX encoding, it
  still uses too much memory:
  * The increase in filesize makes it unusable for even middling sized
    .CO programs on 8K machines.
  * The BASIC loader could be shorter.
  * If loaded using RUN "COM:...", the machine language program is in
    memory twice, once in the DATA statements of the BASIC program and
    a second time as the M/L executable in high memory.
  * If loaded first as a .DO file and then RUN, the program is in
    memory three times: the .DO file is separate from the tokenized
    BASIC program which is created automatically on RUN.
  * I do not know how to run NEW (possibly KILL?) to clear up memory
	before using CALL in a platform independent way.
* It ought to give better instructions for how to use it.

## Future directions:

1. An actual compression algorithm, like Lempel-Ziv, if it can be done
   in a short enough program.
2. An assembly level compressor.
3. A universal serial loader which can load a .CO file from "COM:" on
   any Model-T.

Number 3 may be the best way forward as it should not take up too much
space to be compatible with all variants. Despite the dialect
differences, it should be possible: the NEC N82 BASIC manual
specifically states that it is no problem to have syntax errors in
code that is not executed.

