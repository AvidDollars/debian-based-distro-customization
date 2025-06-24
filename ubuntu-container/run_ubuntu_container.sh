#!/usr/bin/env bash

### TODOs #####################################################
# conditionally create inventory file (just IPs / IPs and headers)
# should contain config file with defaults (e.g. default distro)
# ERROR: /usr/bin/ssh-copy-id: ERROR: ssh: connect to host 172.17.0.2 port 22: Connection refused
#   ->  but only the for 1st run

###############################################################
#
# author: Dimitrij Kolničenko
#
# functionality:
#   - spins Ubuntu container(s) with running SSH server
#   - to be used as Ansible target for tesing Ansible commands/playbooks
#
# usage:
#   ./run_ubuntu_container
#       ->  spins one container
#
#   ./run_ubuntu_container count=<count>
#       ->  spins <count> number of containers
#
#   ./run_ubuntu_container file=servers
#       ->  spins containers whose image names are specified in "servers" file
#
#   ./run_container image=debian count=2
#       ->  spins two Debian containers
#
###############################################################

set -e

MAX_CONTAINERS=10
CONTAINER_IDX=1
NAME=ubu-ssh
FILE=""

# Dockerfile args -> image name, image version, package manager of a distribution
IMAGE=ubuntu
VERSION=latest
PKGMAN=apt
CONTAINERS=1

# Consumes CLI keyword-args if provided.
for ARGUMENT in "$@"; do
    KEY=$(echo $ARGUMENT | cut -f1 -d=)
    KEY_LENGTH=${#KEY}
    VALUE="${ARGUMENT:$KEY_LENGTH+1}"

    # ignore other args if "file" provided
    if [[ $KEY == "file" ]]; then
        echo "'file' argument was specified. All other arguments will be ignored."
        CONTAINERS=$(grep -cve "^\s*$" $VALUE)
        FILE="$VALUE"
        break
    fi

    # overwrite defaults if provided
    [[ $KEY == "image" ]] && IMAGE=$VALUE && continue
    [[ $KEY == "version" ]] && VERSION=$VALUE && continue
    [[ $KEY == "pkgman" ]] && PKGMAN=$VALUE && continue

    if [[ $KEY == "count" ]]; then

        count=$(($VALUE)) # if error on int(input), result will be "0"

        if (($count == 0)); then
            >&2 echo "invalid argument '$VALUE' provided for containers count" && exit 23
        fi

        CONTAINERS=$count
        continue
    fi

    # exit with error on invalid key
    >&2 echo "'$KEY' is invalid argument" && exit 17
done

function _fn_exit_on_missing_dependency() {
    [[ $# -eq 0 ]] && echo "no argument provided" && exit 42

    for dependency in "$@"; do
        command -v $dependency >/dev/null 2>&1 || \
        (echo "'$dependency' is not installed" && exit 42)
    done
}

function _fn_exit_on_already_running_container() {
    if [[ $(docker inspect -f '{{.State.Running}}' $NAME 2> /dev/null) = "true" ]]; then
        >&2 echo "container is already running!"
        exit 42
    fi
}

# Starts container with running SSH server.
# IP address of running container is put into "inventory" file
function _fn_run_container() {
    local name=$NAME-$CONTAINER_IDX

    docker build -t $name \
        --build-arg IMAGE_NAME=$IMAGE \
        --build-arg VERSION=$VERSION \
        --build-arg PACKAGE_MANAGER=$PKGMAN . && \
    \
    docker run --rm -itd \
        --name $name $name /bin/bash \
        -c '/etc/init.d/ssh start && /bin/bash' && \
    \
    local IP=$(docker inspect --format "{{ .NetworkSettings.IPAddress }}" $name)
    [[ -z $IP ]] && >&2 echo "Cannot extract IP address of a container. Make sure container is running." && exit 1

    ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R $IP && \
    sshpass -p root ssh-copy-id -o StrictHostKeyChecking=no -i ~/.ssh/ansible.pub root@$IP && \
    echo $IP >> inventory
}

################## MAIN PROCEDURE ##################
_fn_exit_on_missing_dependency docker sshpass ansible

if [[  $CONTAINERS -gt 1 ]]; then
    iterations=$(($CONTAINERS)) # if error on int(input), result will be "0"

    if (($iterations == 0)); then
        >&2 echo "invalid argument '$1' provided for containers count" && exit 23
    fi

    if (($iterations > $MAX_CONTAINERS)); then
        >&2 echo "OMFG! Too much containers... max is $MAX_CONTAINERS." && exit 13
    fi
fi

CONTAINERS_COUNT="$CONTAINERS"
./kill_containers.sh &> /dev/null || true
echo -n > inventory # clears previous inventory file

# read lines from file if "file" argument specified
if [ -n "$FILE" ]; then
    while read line; do
        if [ -n "$line" ]; then
            SERVERS[$index]="$line"
            index=$(($index+1))
        fi
    done < $FILE
fi

for idx in $(seq 1 $iterations); do
    CONTAINER_IDX=$idx

    if [ -n "$FILE" ]; then
        NAME="${SERVERS[$idx-1]}-ssh"
    fi

    _fn_exit_on_already_running_container
    _fn_run_container
done
