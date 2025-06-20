#!/usr/bin/bash

containers=$(docker ps -a -q --no-trunc --filter name=^ubu-ssh-)
[[ -z $containers ]] && >&2 echo "no containers to kill" && exit 69
docker kill $containers
docker rm $containers 2> /dev/null || true
