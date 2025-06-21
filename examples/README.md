## Spin two containers and install Vim with Ad-Hoc command on both
```sh
# create 2 containers
./run_ubuntu_container.sh 2

# install Vim with apt on both
ansible all -m apt -a name=vim

# SSH to 1st container and check that Vim is now installed
./ssh_to_target.sh
which vim
```

## Edit PS1 variable for all running containers
```sh
# edit PS1 variable with task specified in the playbook
ansible-playbook custom_prompt.yml
```
