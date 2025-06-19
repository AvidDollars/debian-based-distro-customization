#!/usr/bin/bash
set -e

###############################################################
# author: Dimitrij Kolničenko
#
# functionality:
#   - spins Ubuntu container with running SSH server
#   - to be used as Ansible target for tesing Ansible playbooks
###############################################################

NAME=ubu-ssh

function _fn_exit_on_already_running_container() {
    if [[ $(docker inspect -f '{{.State.Running}}' $NAME 2> /dev/null) = "true" ]]; then
        >&2 echo "container is already running!"
        exit 42
    fi
}

# interactive   -> user will have access to bash shell in running container
# detached      -> container will be running in detached mode
function _fn_ask_for_container_mode() {
    read -p "Choose container mode: interactive/detached (i/d)? " choice
    case "$choice" in 
        i|I ) MODE="-it";;
        d|D ) MODE="-itd";;
        * ) >&2 echo "invalid option" && exit 69;;
    esac
}

# Starts container with running SSH server.
# IP address of running container is put into "inventory" file
function _fn_run_container() {
    docker build -t $NAME . && \
    docker run --rm $MODE --name $NAME $NAME /bin/bash -c '/etc/init.d/ssh start && /bin/bash' && \
    IP=$(docker inspect --format "{{ .NetworkSettings.IPAddress }}" $NAME) && \
    ssh-keygen -f "/home/$USER/.ssh/known_hosts" -R $IP && \
    ssh-copy-id -i ~/.ssh/ansible.pub root@$IP # interactive input, provide: "yes" && "root" (password)
    echo $IP > inventory
}


############# PROCEDURE #############
_fn_exit_on_already_running_container
_fn_ask_for_container_mode
_fn_run_container
############# PROCEDURE #############
