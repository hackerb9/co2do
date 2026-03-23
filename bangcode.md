# Bang Code

Bang encoding (or _"!-encoding"_ or _"that thing that Stephen Adolph
came up with that's kinda like yEnc"_) is a way of transforming the
bytes of a binary file so that they can be safely transmitted using
the BASIC "LOAD" and "RUN" commands to a TRS-80 Model 100 (or any of
its sister Portable Computers based on the Kyotronic-85.)

There are two parts to scheme: character code rotation and character
substitution.

## Character rotation

Rotation is merely an optimization to save space. When Rotation=0,
nothing is changed. Otherwise it is a number which is added to every
character code when encoding, modulo 256. For example, with a rotation
of 136, a NULL (code 0) would be sent as BELL (code 7).

## Character substitution

If a character cannot be sent as-is, first a `!` character is sent and
then the character is written with the high-bit flipped. (Note: all
chars from 128 to 255 can be sent verbatim.) For example, the DELETE
character, which is character code 127, would be sent as `!▒`
(character 33 followed by character 255). 

## Quick Examples:

| ROTATION | INPUT  | OUTPUT | Commentary                                    |
|---------:|--------|--------|-----------------------------------------------|
|        0 | ABC123 | ABC123 | ASCII characters from 32 to 126 are unchanged |
|        0 | ♤℅▒πå  | ♤℅▒πå  | Characters from a 128 to 255 are unchanged    |
|        0 | \x7F   | !\xFF  | Delete (127) is mapped to !, 255              |

## What characters need to be escaped? 

| Characters         | Why                                                   |
|--------------------|-------------------------------------------------------|
| ^Z, ^S, and ^Q     | Built-in RS-232 routines use these for EOF, XOFF, XON |
| Characters 0 to 31 | Removed by BASIC during tokenization step             |
| `"`                | Embedded double-quote is difficult in DATA statements |
| `!`                | As the escape character, `!` itself must be escaped   |






