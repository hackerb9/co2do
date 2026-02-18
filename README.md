# co2do

Given a .CO machine language file for a TRS-80 Model 100 (or similar),
creates a .DO file containing a BASIC loader which will install the .CO
to the correct address using POKE and then start it.

## Usage

1. co2do FOO.CO
2. Transfer FOO.DO to M100.
3. On M100: run "FOO"

## Installation

It's just a shell script. Just [download][co2do] it, mark it executable, and
run it.

[co2do] co2do

``` shell
wget https://github.com/hackerb9/co2do/co2do
chmod +x co2do
./co2do FOO.CO
```

## Features

* Inspired by Stephen Adolph's efficient encoding scheme which
  increases storage size by at most 2x + k (where k is approx. 600),
  and on average closer to 1.3x + k.

* Works on any of the Kyotronic Sisters: 
    Kyocera Kyotronic 85, TRS-80 Model 100/102, Tandy 200, 
    NEC PC-8201A/8300, and Olivetti M10.

* BASIC Automatically CLEARs the correct space and CALLs the program.

* Uses .CO header to detect where to POKE, length mismatch, and CALL addr.

* As a special bonus, if you use the -t option, it will display a
  Unicode version of the program instead of writing to a .DO file.
  (Requires the tandy-200.charmap file from hackerb9/tandy-locale.)

## Todo:

* Move length check out of BASIC code to save space.

* Prevent POKEing to bad parts of RAM.
  (E.g., `POKE Q` where `Q<HIMEM` or `Q>=MAXRAM`).

## See also

* Brian K. White includes in his dl2 project a very nice
  [co2ba.sh][co2ba] program which is similar but has different
  features. It allows one to specify the loading address and a comment
  on the command line.

[co2ba]: https://github.com/bkw777/dl2/blob/master/co2ba.md
