# Ansible Projects Notes

Foobar is a Python library for dealing with word pluralization.

## Ubuntu SSH PuttyGen

```bash

PuttyGen on MSFT host > Generate > Move mouse in box for randomness
Save Both Public and Private key to hidden folder in GIT
SSH to Linux box desired
CD to /.ssh folder for user desired, if not create folder

> mkdir .ssh

Create file 

> touch authorized_keys 

> sudo apt-get update
> sudo nano authorized_keys

Select All Public Key in PuttyGen and paste in authorized_keys > Save and exit
Set Box to block non Key based access

>sudo vim /etc/ssh/sshd_config

PermitRootLogin prohibit-password
PasswordAuthentication no

After done, restart ssh > sudo systemctl restart sshd.service
to add Private Key for putty > Connection > SSH > Auth > add Private Key
add hostname info and save  with name

FYSA TIP: Connection was being refused. Had to install new openssh version

>sudo apt install openssh-server
>sudo systemctl status ssh

```

## Ansible Setup from Master

```ansible



```

## License
[MIT](https://choosealicense.com/licenses/mit/)