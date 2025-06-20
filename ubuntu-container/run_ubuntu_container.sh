#!/usr/bin/env bash

###############################################################
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
#   ./run_ubuntu_container <count>
#       ->  spins <count> number of containers
###############################################################

set -e
MAX_CONTAINERS=10
CONTAINER_IDX=1
NAME=ubu-ssh

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

    docker build -t $name . && \
    docker run --rm -itd --name $name $name /bin/bash -c '/etc/init.d/ssh start && /bin/bash' && \
    IP=$(docker inspect --format "{{ .NetworkSettings.IPAddress }}" $name) && \
    ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R $IP && \
    ssh-copy-id -i ~/.ssh/ansible.pub root@$IP # TODO: use "sshpass" so that script in non-interactive
    echo $IP >> inventory
}


################## MAIN PROCEDURE ##################
if [[ $# -gt 0 ]]; then
    iterations=$(($1)) # if error on int(input), result will be "0"

    if (($iterations == 0)); then
        >&2 echo "invalid argument '$1' provided" && exit 23
    fi

    if (($iterations > $MAX_CONTAINERS)); then
        >&2 echo "OMFG! Too much containers... max is $MAX_CONTAINERS." && exit 13
    fi
fi

echo -n > inventory # clears previous inventory file

CONTAINERS_COUNT="$1"

for idx in $(seq 1 $iterations); do
    CONTAINER_IDX=$idx
    _fn_exit_on_already_running_container
    _fn_run_container
done
