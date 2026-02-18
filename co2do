#!/bin/bash -e
# co2do.sh
# by hackerb9, February 2026
#
# Given a .CO machine language file for a TRS-80 Model 100 (or similar),
# creates a .DO file containing a BASIC loader which will install the .CO
# to the correct address using POKE and then start it.
#
# USAGE: co2do.sh FOO.CO FOO.DO
#        Transfer FOO.DO to M100.
#        On M100: run "FOO"
#
# Features:
#
# * Inspired by Stephen Adolph's efficient encoding scheme which
#   increases storage size by at most 2x + k (where k is approx. 600),
#   and on average closer to 1.3x + k.
#
# * Works on any of the Kyotronic Sisters: 
#     Kyocera Kyotronic 85, TRS-80 Model 100/102, Tandy 200, 
#     NEC PC-8201A/8300, and Olivetti M10.
#
# * BASIC Automatically CLEARs the correct space and CALLs the program.
#
# * Uses .CO header to detect where to POKE, length mismatch, and CALL addr.
#
# * As a special bonus, if you use the -t option, it will display a
#   Unicode version of the program instead of writing to a .DO file.
#   (Requires the tandy-200.charmap file from hackerb9/tandy-locale.)

# Todo: * Move length check out of BASIC code to save space.
#       * Prevent POKEing to bad parts of RAM.
#         (E.g., POKE Q where Q<HIMEM or Q>=MAXRAM).


function usage() {
    cat <<EOF
Usage: co2do.sh <INPUT.CO> [OUTPUT.DO]
EOF
}

function main() {
    declare -i TOP LEN EXE
    TOP=$1+$2*256
    LEN=$3+$4*256
    EXE=$5+$6*256
    shift 6
cat<<EOF >&2
TOP: $TOP
END: $((TOP+LEN))
EXE: $EXE
EOF
cat <<EOF
10 CLEAR 256, $TOP
20 TP=$TOP: LN=$LEN: EX=$EXE
30 GOSUB 13000
40 IF PEEK(1)<>148 THEN CALL EX ELSE EXEC EX
50 END
13000 'Decode ML
13010 CLS:Q=$TOP:H$=CHR\$(27)+"H"
13020 ?H$"       / $((TOP+LEN-1)) $input"
EOF
    emitbasicdecode
    printf "14000 '$input"
    printdata "$@"
}

function printdata() {
    local -i linenum=14000 
    local -i v
    for v; do
	if (( count++ % 120 == 0 )); then
	    printf '\n%d DATA"' $((linenum+=10))
	fi
	# Escape quotation mark, slash, delete, and ctrl chars (except tab)
	if (( (v<32 && v!=9) || v==34 || v==23 || v==47 || v==127 )); then
	    v=v+128
	    printf "/"
	fi
	printf -v x "%x" $v
	printf "\x$x"
    done
    # End of DATA marked by '//'
    printf '\n%d DATA"//"\n' $((linenum+=10))
}

function emitbasicdecode() {
    # Credit to Stephen Adolph for the decode routine and encoding scheme.
    # Any errors are mine (hackerb9).
    # Modifications:
    # * autodetect the load address from binary.
    # * use the invalid sequence "//" for End of Data,
    #   which allows me to quote DEL (7F) using "/\xFF".
    # * subtract 128 instead of adding it, just for aesthetics.
    # * double check the filesize matches the header length.
    # * do not discard a quoting "/" at the end of a DATA line.
    cat <<"EOF"
13030 READP$:FORX=1TOLEN(P$):a$=MID$(P$,X,1)
13040 if a$="/" then if e=1 then 13080: else e=1: goto 13070
13050 v=asc(a$): if e=1 then v=v-128: e=0
13060 ?H$q:POKEQ,v:Q=Q+1
13070 NEXTx:GOTO13030
13080 IF LN<>(q-TP) THEN ?:?"Error:",LN"<>"q-TP:END
13090 RETURN
EOF
}


{
    # CLI args
    tandycharset=cat
    if [[ "$1" == "-t" ]]; then
	shift
	tandycharset="iconv -f $(dirname $0)/tandy-200.charmap"
    fi
    if [[ "$1" == "-" ]]; then shift; set -- /dev/stdin "$@"; fi

    if [ -z "$1" ]; then
	usage
	exit 1
    elif [ ! -r "$1" ]; then
	echo "'$1' is not readable"
	exit 1
    else
	input="$1"
	shift
    fi

    output=/dev/stdout
    if [ "$1" ]; then
	output="$1"
	shift
    elif [[ $tandycharset == "cat" ]]; then
	if [[ $input == *.CO ]]; then
	    output=${input%.CO}.DO
	elif [[ $input == *.co ]]; then
	    output=${input%.co}.do
	fi
    fi
}
main $(od -t u1 -v -An "$input") | $tandycharset > "$output"

if [[ $tandycharset == "cat" ]]; then
    outnodo=${output##*/}
    outnodo=${outnodo%.[Dd][Oo]}
cat <<EOF
Now transfer $output to your Model-T
and in BASIC type
    run "$outnodo"
EOF
fi
