# Digital Ocean custom Ubuntu 20.04 image

Install `unzip`, `apt-transport-https`, `htop`.

Create user `ansible` with home directory `/home/ansible`, set ssh public key for current user
for `/home/ansible/.ssh/authorized_keys` and enable password authentication.

```shell script
export PERSONAL_DO_TOKEN=<token>
packer build -var-file=variables.json template.json
```