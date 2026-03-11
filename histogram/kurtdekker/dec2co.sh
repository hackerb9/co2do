#!/bin/bash -e

# Given the name of a file in Kurt Dekker's .DEC format,
# Output a .CO file of the same name.

export IFS=$',\n \x1A'		# Split on commas, newlines; ignore ^Z
for file; do
    if [ ! -r "$file" ]; then echo "Unable to read '$file'">&2; continue; fi
    output=${file%.DEC}.CO
    echo output is $output
    set - $(tail +1 $file | tr ',\r\n' ' ')
    exec 5>&1
    exec 1>$output
    top=$1 end=$2 exe=$3 linelen=$(($4+1))
    shift 4
    printf "TOP: %d\nEND: %d\nEXE: %d\n" $top $end $exe >&5
    declare -i len=$((end - top + 1))
    printf -v x "%04x" $top; printf "\x${x:2:2}\x${x:0:2}"
    printf -v x "%04x" $len; printf "\x${x:2:2}\x${x:0:2}"
    printf -v x "%04x" $exe; printf "\x${x:2:2}\x${x:0:2}"

    declare -i t=0 sum=0 count=0
    for byte; do
	if (( (t+++1) % linelen == 0 )); then
	    printf "\r%d/%d " $t $# >&5
	    if (( $byte == $sum )); then 
		printf "okay" >&5
	    else	    
		printf "Error bad checksum %d != %d\n" $sum $byte >&5
		break
	    fi
	    sum=0
	    continue
	fi
	if (( count >= len )); then break; fi
	count=count+1
	if ! printf -v x "%x" $byte; then
	    printf "Bad data in '$file'">&2;
	    break
	fi
	printf "\x$x"
	sum=sum+$byte
    done
    exec >&5
    printf "\t$((count+6)) bytes"
    printf '\t%s\n' $output

done

