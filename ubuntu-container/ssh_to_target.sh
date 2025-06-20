#!/usr/bin/bash
set -e

################################################
#    SSH TO RUNNING DOCKER CONTAINER
#
#   usage:
#       ./ssh_to_target.sh
#           ->  will use 1st IP from ./inventory
#
#       ./ssh_to_target.sh <line-num>
#           ->  will use IP from line in file specified by <line-num>
#           ->  index starts from 1
#
################################################

FILENAME="./inventory"

if [[ ! -f $FILENAME ]]; then
    >&2 echo "'$FILENAME' does not exist!"
    exit 69
else
    if [[ $# -gt 0 ]]; then

        idx=$(($1)) # if error on int(input), result will be "0"
        if (($idx == 0)); then
            >&2 echo "'$1' is not valid index" && exit 23
        fi

        ip=$(awk "NR == $idx" $FILENAME)

        if [[ -z $ip ]]; then
            >&2 echo "no IP address present on line $1" && exit 13
        fi
    else
        ip=$(head -n 1 $FILENAME | tr -d '[:space:]')

        if [[ -z $ip ]]; then
            >&2 echo "invalid IP address found in '$FILENAME'"
            exit 42
        fi
    fi
fi

ssh root@$ip
