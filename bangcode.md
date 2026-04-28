# Bang Code

Bang encoding (or _"!-encoding"_ or _"that thing that Stephen Adolph
came up with that's kinda like yEnc"_) is a way of transforming the
bytes of a binary file so that they can be safely transmitted using
the BASIC "LOAD" and "RUN" commands to a TRS-80 Model 100 (or any of
its sister Portable Computers based on the Kyotronic-85.)

There are two parts to scheme: character code rotation and character
substitution. When encoding, rotation comes first, but since it is an
optional frill, it will be covered second.

## Character substitution

After rotation, if a character cannot be sent as-is, first a `!`
character is sent as an escape followed by the character written with
the high-bit flipped. For example, the DELETE character, which is
character code 127, would be sent as `!▒` (character 33 followed by
character 255).

* Note that all chars from 128 to 255 can be received and saved
  in BASIC programs on the Model T computers.

## Character rotation

Rotation is merely an optimization to save space. When Rotation=0,
nothing is changed. Otherwise it is a number which is added to every
character code when encoding, modulo 256. For example, with a rotation
of 136, a NULL (code 0) would be sent as ’¡’ (code 136) and a ’x’
(code 120) would become a NULL.

## Quick Examples:

| ROTATION | INPUT   | OUTPUT               | Commentary                                                                   |
|---------:|---------|----------------------|------------------------------------------------------------------------------|
|        0 | ABC123  | ABC123               | ASCII characters from 32 to 126 are unchanged                                |
|        0 | ♤℅▒πå   | ♤℅▒πå                | Characters from a 128 to 255 are unchanged                                   |
|        0 | \00\x7F | !☎!▒                 | NULL (0) is mapped to !, 128 and Delete (127) is mapped to !, 255            |
|     +136 | \00     | ¡                    | With rotation NULL (0) is mapped to ¡ (136) which saves a byte               |
|     +136 | \x7Fxyz | !\x87!\x80!\x81!\x82 | Rotation generally means fewer characters need to be escaped, but not always |


## What characters need to be substituted and why?

| Characters          | ASCII  | !-code       | Why                                                     |
|---------------------|--------|--------------|---------------------------------------------------------|
| Characters 0 to 8   | 0..8   | 33, 128..136 | Removed by BASIC during tokenization step               |
| Characters 10 to 31 | 10..31 | 33, 138..159 | "                                                       |
| `!`                 | 33     | 33, 161      | As the escape character, `!` itself must be escaped     |
| `"`                 | 34     | 33, 162      | Embedded double-quote is difficult in DATA statements   |
| ^Z                  | 26     | 33, 154      | Removed during serial transfer by BASIC ROM (^Z is EOF) |
| ^S                  | 19     | 33, 147      | " (^S is XOFF)                                          |
| ^Q                  | 17     | 33, 145      | " (^Q is XON)                                           |
| Delete              | 127    | 33, 255      | Removed by EDIT program                                 |

* Note that characters 9 (tab) and 32 (space) _are_ allowed.




