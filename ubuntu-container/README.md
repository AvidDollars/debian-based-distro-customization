> [!CAUTION]
> To be used locally only for testing purposes.

> [!WARNING]
> Running the scripts may overwrite the content of "/home/$USER/.ssh/known_hosts" file
> Before spinning containers, entries for their private IP addressess are removed from SSH known hosts

## Info
You can spin Ubuntu container if no remote target for testing Ansible playbooks is available.

## Prerequisities
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) installed
- [Docker](https://docs.docker.com/engine/install/) installed
- [SSHPass util](https://gist.github.com/arunoda/7790979) installed

## Running Ubuntu Container
```bash
# script is interactive:
#   ->  provide "yes" on asking about the authenticity
#   ->  provide "root" for password when copying "ansible key" public key to the container

# start Ubuntu container:
./run_ubuntu_container.sh
```

## Running playbook
```bash
# You can test if everyhing is working correctly by running provided playbook.
# You will be prompted to provide root password (password: "root"):
ansible-playbook custom_prompt.yml # uses prompt from current user and sets it for "root" in the container
```

## SSH into the target
```bash
# IP address from first line in ./inventory will be used
./ssh_to_target

# takes IP from line (index starts from 1) 
./ssh_to_target <line-num>

# or pick IP address interactively
./interactive_ssh_to_target.sh
```

## Killing running containers
```bash
./kill_containers.sh
```
