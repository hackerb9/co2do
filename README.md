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

* As a special bonus, if you use the -t option, it will display a
  Unicode version of the program instead of writing to a .DO file.
  (Requires the [tandy-200.charmap file][charmap] from
  [hackerb9/tandy-locale][tandy-locale].)
  ![Example of -t output][charmapimg]

[charmap]: https://raw.githubusercontent.com/hackerb9/co2do/main/tandy-200.charmap
[charmapimg]: README.md.d/charmapimg.png

[tandy-locale]: https://github.com/hackerb9/tandy-locale/


## Todo

* Move length check out of BASIC code to save space.

* Prevent POKEing to bad parts of RAM.
  (E.g., `POKE Q` where `Q<HIMEM` or `Q>=MAXRAM`).

## Misfeatures

* The shell script could, but does not yet, emit a warning if the
  created .CO file would not run on certain machines. (For example if
  TOP<=57777 on 8K machines or END>=61104 on a TANDY 200).  
  It could also adjust the string allocation in CLEAR to be less if need be.

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
