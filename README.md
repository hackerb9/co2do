# co2do

Convert a .CO (machine language) file to .DO (BASIC Loader) for easy download.

Machine language programs (.CO files) cannot be downloaded over the
serial port using the built-in software on a TRS-80 Model 100 (or
kin). The usual solution is to install more software ([Teeny][teeny],
[TSDOS][tsdos], [TBACK][tback]). This program is an alternative that
tries to make it as easy as possible for the end user.

[teeny]: https://www.youtube.com/watch?v=H0xx9cOe97s
[tsdos]: https://www.club100.org/library/doc/tsdos.html
[tback]: https://bitchin100.com/wiki/index.php?title=TBACK

Given a .CO file, co2do creates a .DO file that the built-in tools can
handle. The .DO file contains a BASIC loader that installs the .CO
data to the correct memory address using a very fast machine language
routine, saves the .CO file, and launches it.

Co2do is simple to use and quite quick. The most important limitation
is that it currently creates quite large .DO files (+2K) which may
not fit on smaller machines.

## Usage

1. co2do FOO.CO
2. Transfer FOO.DO to M100.
3. On M100: run "FOO"

## Installation

It's a shell script. Simply [download co2do][co2do], mark it
executable, and run it on any UNIX-ish operating system.

[co2do]: https://raw.githubusercontent.com/hackerb9/co2do/main/co2do

``` shell
wget https://raw.githubusercontent.com/hackerb9/co2do/main/co2do
chmod +x co2do
./co2do FOO.CO
```

> _This script depends on UNIX tools like `od` and `sed`, so any
> POSIX-compliant system with bash can work. (Linux definitely does,
> BSD should, MacOS could, Windows WSL ???)._

## Features

* Works on any portable computer descended from the Kyocera Kyotronic
  85: The TRS-80 Model 100/102, Tandy 200, NEC PC-8201A/8300, and
  Olivetti M10.

* Uses the .CO header to detect destination address, length mismatch,
  and CALL addr.

* Creates .DO files that can be easily loaded over the serial port
  without any extra software. (For example, `RUN "COM:88N1"`.) 
  
* Includes the ^Z marker at the end of the .DO file so no software is
  needed on your host computer, either. Anything that can write to the
  serial port will work — Even the DOS "COPY" command!

* Once transferred, the BASIC loader writes the .CO to memory in less
  than a second using a machine language routine. (Previously, the same
  task took minutes in BASIC.)

* Automatically CLEARs the correct space, SAVEMs the .CO file, and
  CALLs the program. (Exception: NEC PCs can either BSAVE or EXEC but
  not both).

* Inspired by Stephen Adolph's [efficient encoding scheme][bangcode]
  which increases storage size by at most 2 _x_ + _k_ (where _x_ is
  the size of the .CO file and _k_ is a constant for the boilerplate
  BASIC code, currently around 2000). By rotating the character set by
  a fixed offset, in practice, the increase is closer to 1.2 _x_ +
  _k_.

* As a special bonus, if you use the `-t` option, it will display a
  Unicode version of the program instead of writing to a .DO file.
  (Requires the [tandy-200.charmap file][charmap] from
  [hackerb9/tandy-locale][tandy-locale], included.)
  ![Example of -t output][charmapimg]

[charmap]: https://raw.githubusercontent.com/hackerb9/co2do/main/tandy-200.charmap
[charmapimg]: README.md.d/charmapimg.png

[tandy-locale]: https://github.com/hackerb9/tandy-locale/

## Known issues

* Too big: The boilerplate BASIC code that gets added is huge (almost
  2000 bytes) completely swamping the savings from the efficient
  encoding. This means some valid .CO programs may not be usable.

* ~~Too slow: A 1500 byte .CO files takes about 40 seconds just to load
  into memory. _(That's 300 baud!)_~~

  * It _was_ too slow, but now that I've added a M/L routine to move
    the data, it is super fast. And... super bloated.

  * The program has not been optimized yet for size, so there is a lot
    of room for improvement.

  * A large part of the increase was the need to add special handling
    for the NEC PC-8201 which lacks VARPTR and uses EXEC/BSAVE instead
    of CALL/SAVEM.

* If memory is small and the file is large, you can get an ?OM error
  when the .DO file is RUN. The solution is to transfer and run the
  .DO file in a single step, directly from the serial port:

  1. Type this BASIC command (pick the one for your machine):
 	 * Model 100, Tandy 102, Kyotronic 85, Olivetti M10<br/>`run "COM:88N1"`
	 * Tandy 200<br/>`run "COM:88N1ENN"`
	 * NEC PC-8201/8300<br/>`run "COM:8N81XN"`
  2. Then on your host PC, send the file to the serial port. For example,
	 GNU/Linux machines can do `cat FILENM.DO >/dev/ttyUSB0`

* No longer warns if the .CO file may not run on certain machines.
  (E.g., for 8K machines if TOP<=57777; for the Tandy 200 if
  END>=61104).

See [todo.md](todo.md) for more specifics.

## Design and Alternatives

Hackerb9 wrote co2do because none of the alternatives at the time were
universal. Using co2do, a single .DO file can be offered that loads on
any of the Kyotronic Sisters: Kyocera Kyotronic 85, TRS-80 Model
100/102, Tandy 200, Olivetti M10, and NEC PC-8201/8201A/8300. While
very [few][crc16] machine language programs can actually run unchanged
on all of those machines, co2do will not impose any limitations.

[crc16]: https://github.com/hackerb9/crc16-modelt/ "Here's one universal .CO program: CRC16"

The secondary design goal is to be simple to use. One should be able
to run co2do without reading any documentation. There are no switches
to flip, no knobs to frob. It just works. (Or doesn't, depending upon
your viewpoint. See co2ba, below.)

A tertiary goal is to be extremely fast to unpack when run on a Model
T computer. That is why hackerb9 wrote the machine language to
[decode][bangcode] and copy the bytes into the correct location in
RAM.

While space efficiency is a goal, no optimization beyond the encoding
has yet been attempted. That will come next now that correctness and
speed have been taken care of.

To save bytes, co2do uses an efficient encoding called "[bang
code][bangcode]" (suggested originally by Stephen Adolf),
characterized by DATA statements contains an exclamation mark to
escape only the characters which cannot be loaded into BASIC.
Additionally, the character-set is "rotated" +136, so that more
frequently used codes (like NULL) will not need to be escaped.

[bangcode]: bangcode.md

### Limitations

The main downside of co2do is that the filesize increases
significantly and some .CO files may not fit. If your programs are not
working on 8K machines, hackerb9 recommends investigating co2ba.

### See also

* **co2ba** Brian K. White includes in his dl2 project a very nice
  [co2ba.sh][co2ba] program which is similar in that it creates BASIC
  loaders, but but has different features. It has been optimized for
  space efficiency and is a good choice if you are tight on memory. It
  also has more command line options, such as manually specifying the
  loading address or the comment to be shown to the user.

[co2ba]: https://github.com/bkw777/dl2/blob/master/co2ba.md

