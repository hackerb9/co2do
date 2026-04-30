## Todo

  * [ ] Make loader small enough to fit in 8K with a reasonably sized
		M/L program. 

	Despite having better compression than the usual HEX encoding, it
	still uses too much memory. The increase in filesize makes it
	unusable for even middling sized .CO programs on 8K machines.

	* [ ] The BASIC loader could be shorter.
		
	* [ ] NEC VARPTR code is ungainly. Refactor or convert to M/L?

  * [ ] Cleanup the ugly warnmem branch. Should only WARN, not ERR if
		the .DO file will not fit.

  * [ ] Sanity checks. 
  
    * [ ] In co2do: Warn the user if the resulting file won't work on
		  machines with limited RAM (higher MINRAM) or have lower
		  MAXRAM (Tandy 200).

    * [ ] In BASIC loader: POKEing >= MAXRAM == big disaster! Maybe
          BASIC loader should check MAXRAM? NEC PC8201 has no "MAXRAM"
          but the PC-8300 techref implies it is a fixed value: 62336.
          We can detect a NEC using PEEK(1)==148. Is this a good use
          of bytes?

  * [ ] Automatically adjust the string space and MAXFILES if the RAM
		limit is close.

  * [ ] Automatically use smaller, slower code if the RAM limit would
        be exceeded.

  * [ ] Double-check that co2do runs under Mac OS and WSL for Microsoft Windows.


## Maybe Do

  * [ ] Investigate handling repositionable payload, re-ORG-ing to
        load immediately under HIMEM. Perhaps this should be a
        different tool, not co2do, as this cannot be done directly
        from a .CO file. Requires the user to supply .LST (an assembly
        listing) or two .CO files ORG'd to 0 and 1. Consider encoding
        using a bangcode extension similar to embedasm:coco().

  * [ ] Maybe read directly from the serial port for even more speed,
        RAM savings.




## Done!

  * [x] Make it easier to have multiple payloads in a single file.

  * [x] Consider using SAVEM automatically if `fre(0)` says there's
		enough space, otherwise create a trigger file.

  * [x] Fix varptr code to work on NEC PC-8201A.

  * [x] For speed, investigate using a **small** M/L program to copy
		the data directly to the correct location and printing status
		to the screen with RST 4.

	* Q: Where can that program live? 
	  A: John Hogerhuis suggests as a string in the BASIC program. 
	* Would have to parse it in BASIC to make it runnable. (Slash
	  escapes, addr relocate). How many bytes does that take?
	* VARPTR is possible on NEC but not builtin. Again, how many bytes?

* [x] Currently the BASIC loader is way too slow due to string parsing
  and printing to the screen. VARPTR might help with the former, but I
  believe M/L is needed to improve printing speed.

* [x] It ought to give better instructions for how to use it.



## Misfeature details: program duplication as .DO, .BA, .CO

 1. If loaded using RUN "COM:...", the payload is in memory twice,
    once in the DATA statements of the BASIC program and a second time
    as the M/L executable in high memory.

 2. If loaded first as a .DO file and then RUN, the program is in
    memory THREE times: the .DO file is separate from the tokenized
    BASIC program which is created automatically on RUN.

 3. I do not know how to run NEW (possibly KILL?) to clear up memory
	before using CALL in a platform independent way.




## Future alternatives research:

1. An actual compression algorithm, like Lempel-Ziv, if it can be done
   in a short enough program.
2. An assembly level compressor.
3. A universal serial loader which can load a .CO file from "COM:" on
   any Model-T.

Number 3 may be the best way forward as it should not take up too much
space to be compatible with all variants. Despite the dialect
differences, it should be possible: the NEC N82 BASIC manual
states specifically that it is no problem to have syntax errors in
code that is not executed.

