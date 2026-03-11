#!/bin/python
from glob import glob as glob
from sys import argv


def accumulate_bytes(filenames):
    for filename in filenames:
        with open(filename, "rb") as fp:
            buf=fp.read()
            for x in buf:
                sums[x]=sums[x]+1
            
def print_histogram_sums():
    for x in range(256):
        print(f'{x:3d}:\t{sums[x]:4d}')


def getsize(sums):
    '''Calculate the filesize after bang-encoding'''
    total = sum([sums[x] for x in sums]) \
        + sum([sums[x] for x in range(35) if x!=9 and x!=32])
    return total

def rotate(sums, k):
    '''Given the table of sums for various bytes, rotate it by k'''
    return { x:sums[(x+k)%256] for x in range(256) }

if __name__ == "__main__":
    sums={x:0 for x in range(256)}
    if len(argv) == 1:
        files="*.[Cc][Oo]"
    else:
        files=argv[1];

    if glob(files) == []:
        print(f"No files matched {files}")
        exit(1)

    accumulate_bytes(glob(files))

    print(f"Unrotated: {getsize(sums)} bytes.")
    size={}
    for k in range(256):
        size[k]=getsize(rotate(sums, k))

    m = min(size.values())
    s = size[0]-m
    print(f"\nCan save {s} bytes ({100*s/size[0]:.2f}%)")

    for k in [ x for x in size if size[x] == m ]:
        print(f"Rotation {k:+3d} => {size[k]} bytes.")
        
    m136=size[136]
    s136=size[0]-m136
    print(f"\nRotation of +136 would save {s136} bytes ({100*s136/size[0]:.2f}%)")

