Hackerb9 defines "MINRAM" as the smallest number HIMEM can be set to
without an ?OM Error, presuming no files, CLEAR 0, and MAXFILES=0.
Note that machines with less memory have the same MAXRAM and a higher
MINRAM.

<details><summary>This table was found by trial and error using Virtual T</summary><ul>

``` BASIC
CLEAR 0
Ok
MAXFILES=0
Ok
?HIMEM
 62960
Ok
?FRE(0)
 4473
Ok
?62960-4473+146
 58633
Ok
CLEAR 0, 58633
Ok
CLEAR 0, 58632
?OM Error
Ok
```

</ul></details>


| Machine      | MINRAM | MAXRAM |
|--------------|-------:|-------:|
| 8K Kyotronic |  58633 |  62960 |
| 8K M100      |  57777 |  62960 |
| 16K M100     |  49585 |  62960 |
| 24K M100     |  41393 |  62960 |
| 32K M100     |  33201 |  62960 |
| Tandy 200    |  41394 |  61104 |
| ____________ | ______ | ______ |
| max/min      |  58633 |  61104 |
