# Bang Code

Bang encoding (or _"!-encoding"_ or _"that thing that Stephen Adolph
came up with that's kinda like yEnc"_) is a way of transforming the
bytes of a binary file so that they can be safely transmitted using
the BASIC "LOAD" and "RUN" commands to a TRS-80 Model 100 (or any of
its sister Portable Computers based on the Kyotronic-85.)

## Quick Example:

```
ABCDEF123456

```

## What characters need to be encoded? 

| Characters         | Why                                                   |
|--------------------|-------------------------------------------------------|
| ^Z, ^S, and ^Q     | Built-in RS-232 routines use these for EOF, XOFF, XON |
| Characters 0 to 31 | Removed by BASIC during tokenization step             |
| `"`                | Double-quote causes confusion in DATA statements




