# co2do

Given a .CO machine language file for a TRS-80 Model 100 (or similar),
creates a .DO file containing a BASIC loader which will install the .CO
to the correct address using POKE and then start it.

## Usage

1. co2do FOO.CO
2. Transfer FOO.DO to M100.
3. On M100: run "FOO"

## Installation

It's just a shell script. Simply [download co2do][co2do], mark it
executable, and run it on any UNIX-ish operating system.

[co2do]: https://raw.githubusercontent.com/hackerb9/co2do/main/co2do

``` shell
wget https://raw.githubusercontent.com/hackerb9/co2do/main/co2do
chmod +x co2do
./co2do FOO.CO
```

> This script depends on UNIX tools like `od` and `awk`, so any
> POSIX-compliant system with bash can work. (Linux definitely, BSD
> should, MacOS could, WSL ???).

## Features

* Inspired by Stephen Adolph's efficient encoding scheme which
  increases storage size by at most 2x + k (where k is approx. 500),
  and on average closer to 1.3x + k.

* Works on any of the Kyotronic Sisters: 
    Kyocera Kyotronic 85, TRS-80 Model 100/102, Tandy 200, 
    NEC PC-8201A/8300, and Olivetti M10.

* BASIC Automatically CLEARs the correct space and CALLs the program.

* Uses .CO header to detect where to POKE, length mismatch, and CALL addr.

* Warns if the .CO file may not run on certain machines. (E.g., for 8K
  machines if TOP<=57777; for the Tandy 200 if END>=61104).

* As a special bonus, if you use the `-t` option, it will display a
  Unicode version of the program instead of writing to a .DO file.
  (Requires the [tandy-200.charmap file][charmap] from
  [hackerb9/tandy-locale][tandy-locale].)
  ![Example of -t output][charmapimg]

[charmap]: https://raw.githubusercontent.com/hackerb9/co2do/main/tandy-200.charmap
[charmapimg]: README.md.d/charmapimg.png

[tandy-locale]: https://github.com/hackerb9/tandy-locale/

## Known issues

* Too big: BASIC loader increases .CO size 1.3x + 500 bytes. This
  means some valid .CO programs may not be usable.

* Too slow: A 1500 byte .CO files takes about 40 seconds just to load
  into memory. _(That's 300 baud!)_

* If memory is small and the file is large, you can get an ?OM error
  when the .DO file is RUN. The solution is to not transfer the .DO
  file first, instead RUN it directly from the serial port:

  1. Type this BASIC command (pick the one for your machine):
 	 * Model 100, Tandy 102, Kyotronic 85, Olivetti M10<br/>`run "COM:88N1"`
	 * Tandy 200<br/>`run "COM:88N1ENN"`
	 * NEC PC-8201/8300<br/>`run "COM:8N81XN"`
  2. Then on your host PC, send the file to the serial port. For example,
	 GNU/Linux machines can do `cat FILENM.DO >/dev/ttyUSB0`


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

## See also

* Brian K. White includes in his dl2 project a very nice
  [co2ba.sh][co2ba] program which is similar but has different
  features. It allows one to specify the loading address and a comment
  on the command line.

[co2ba]: https://github.com/bkw777/dl2/blob/master/co2ba.md
