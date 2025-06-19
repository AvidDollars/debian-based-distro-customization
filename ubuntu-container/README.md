## Info
> [!CAUTION]
> To be used locally only for testing purposes.
You can spin Ubuntu container if no remote target for testing Ansible playbooks is available.

## Prerequisities
- [Ansible](https://docs.ansible.com/ansible/latest/installation_guide/intro_installation.html) installed
- "ansible key" key-pair present in "~/.ssh/ansible" on host machine

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
ansible-playbook --ask-become-pass custom_prompt.yml # uses prompt from current user and sets it for "root" in the container
```

## SSH into the target
```bash
./ssh_to_target
```
