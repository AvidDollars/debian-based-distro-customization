#!/usr/bin/bash
set -e

FILENAME="./inventory"

if [[ ! -f $FILENAME ]]; then
     >&2 echo "'inventory' file does not exist!"
     exit 69
else
    ip=$(head -n 1 $FILENAME | tr -d '[:space:]')
    ssh root@$ip
fi