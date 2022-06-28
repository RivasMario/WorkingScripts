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

```bash

Connect to all servers from master and select yes on prompt

Generate an ssh key that’s going to be specifically used for Ansible

> ssh-keygen -t ed25519 -C "homelabansible"
FYSA: Run in .ssh folder

Copy the ssh key to the server(s)

> ssh-copy-id -i ~/.ssh/homelabansible.pub ubuntu@192.168.0.19 <IP>
FYSA: Need to specify user when sending

Use an SSH key to connect to a server 

>ssh -i ~/.ssh/homelabansible ubuntu@192.168.0.19 <IP Address>

To cache the passphrase for our session, we can use the ssh agent 

>eval $(ssh-agent)
>ssh-add  

~/.ssh/homelabansible

Here’s an alias you can put in your .bashrc, to simplify it

> alias ssha='eval $(ssh-agent) && ssh-add'

```

## Ansible, Setting up GIT repo

```bash

Need to create a SSH key-pair on localhost. Add private to ssh-agent. Add Public to Github. Pull New Ansible Repo to server.

Check if git is installed

>which git

Install git

>sudo apt update
>sudo apt install git

Create user config for git

>git config --global user.name "RivasMario"
>git config --global user.email "mariojrivas@outlook.com"

Check the status of your git repository

>git status

Stage the README.md file (after making changes) to be included in the next git commit

>git add README.md

Set up the README.md file to be included in a commit

>git commit -m "Updated readme file, initial commit"

Send the commit to Github

>git push origin main
FYSA: Main not Master

FYSA: Github keys
ssh-keygen -t ed25519 -C "your_email@example.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/githubansible

ssh -T git@github.com
git clone git@github.com:RivasMario/AnsibleHomelab.git
```

## Ansible Ad-Hoc commands

```bash
Install ansible

>sudo apt update
>sudo apt install ansible

Create an inventory file (add the IP address for each server on its own line)

192.168.0.102
192.168.0.103
192.168.0.104
192.168.0.105
192.168.0.106
192.168.0.107

Add the inventory file to version control

>git add inventory

Commit the changes

>git commit -m "first version of the inventory file, added three hosts."

Push commit to Github

>git push origin master

Test Ansible is working

>ansible all --key-file ~/.ssh/ansible -i inventory -m ping

Create ansible config file

>nano ansible.cfg
 
[defaults]
inventory = inventory private_key_file = ~/.ssh/ansible

Now the ansible command can be simplified

>ansible all -m ping

List all of the hosts in the inventory

>ansible all --list-hosts

Gather facts about your hosts

>ansible all -m gather_facts

Gather facts about your hosts, but limit it to just one host

>ansible all -m gather_facts --limit 172.16.250.132


```

## License
[MIT](https://choosealicense.com/licenses/mit/)