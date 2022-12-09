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

>ssh -i ~/.ssh/homelabansible ubuntu@192.168.0.$ (102-107) <IP Address>

To cache the passphrase for our session, we can use the ssh agent 

>eval $(ssh-agent)
>ssh-add  

~/.ssh/homelabansible

---------
eval $(ssh-agent)
ssh-add  ~/.ssh/homelabansible
ssh-add  ~/.ssh/githubansible
---------

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

FYSA: Need to add the private key to github itse;f in ssh gpg keys section 10/10/2022

ssh -T git@github.com
git clone git@github.com:RivasMario/AnsibleHomelab.git
git remote add origin git@github.com:RivasMario/AnsibleHomelab.git
git push origin main
```

## Ansible Ad-Hoc commands

```bash
Install ansible package

>sudo apt update
>sudo apt install ansible

Create an inventory file (add the IP address for each server on its own line)

nano inventory
git add inventory
git commit -m "inventory"
git push origin master

192.168.0.102
192.168.0.103
192.168.0.104
192.168.0.105
192.168.0.106
192.168.0.107

Add the inventory file to version control

>git add inventory

Commit the changes

>git commit -m "first version of the inventory file, added six hosts."

Push commit to Github

>git push origin master

Test Ansible is working

>ansible all --key-file ~/.ssh/homelabansible -i inventory -u ubuntu -m ping

Create ansible config file

>nano ansible.cfg
  
[defaults]
inventory = inventory 
private_key_file = ~/.ssh/homelabansible

Now the ansible command can be simplified

>ansible all -m ping -u ubuntu

List all of the hosts in the inventory

>ansible all --list-hosts -u ubuntu

Gather facts about your hosts

>ansible all -m gather_facts -u ubuntu

Gather facts about your hosts, but limit it to just one host

>ansible all -m gather_facts --limit 172.16.250.132 -u ubuntu

```

## Running elevated ad-hoc commands

```bash

Tell ansible to use sudo (become)

>ansible all -m apt -a update_cache=true --become --ask-become-pass -u ubuntu

Install a package via the apt module

>ansible all -m apt -a name=vim-nox --become --ask-become-pass -u ubuntu

Install a package via the apt module, and also make sure it’s the latest version available

>ansible all -m apt -a "name=snapd state=latest" --become --ask-become-pass -u ubuntu

Upgrade all the package updates that are available

>ansible all -m apt -a "upgrade=dist" --become --ask-become-pass -u ubuntu


```

## Ansible First playbook

```yml

install_apache.yml

 ---
 
 - hosts: all
   become: true
   tasks:
 
   - name: install apache2 package
     apt:
       name: apache2


Run the playbook

>ansible-playbook --ask-become-pass -u ubuntu install_apache.yml

install_apache.yml (second version)
 ---
 
 - hosts: all
   become: true
   tasks:
 
   - name: update repository index
     apt:
       update_cache: yes
 
   - name: install apache2 package
     apt:
       name: apache2

install_apache.yml (third version)
 ---
 
 - hosts: all
   become: true
   tasks:
 
   - name: update repository index
     apt:
       update_cache: yes
 
   - name: install apache2 package
     apt:
     name: apache2
 
   - name: add php support for apache
     apt:
       name: libapache2-mod-php

install_apache.yml (fourth version)
 ---
 
 - hosts: all
   become: true
   tasks:
 
   - name: update repository index
     apt:
       update_cache: yes
 
   - name: install apache2 package
     apt:
       name: apache2
       state: latest
 
   - name: add php support for apache
     apt:
       name: libapache2-mod-php
       state: latest

remove_apache.yml
 ---
 
 - hosts: all
   become: true
   tasks:
 
   - name: remove apache2 package
     apt:
       name: apache2
       state: absent
 
   - name: remove php support for apache
     apt:
       name: libapache2-mod-php
       state: absent

```

## The ‘when’ Conditional

```yml

install_apache.yml

 ---
 
 - hosts: all
   become: true
   tasks:
 
   - name: update repository index
     apt:
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
   - name: install apache2 package
     apt:
       name: apache2
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: add php support for apache
     apt:
       name: libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"

when: ansible_distribution == ["Debian","Ubuntu"]

also works as an array

///////////

>ansible-playbook --ask-become-pass -u ubuntu install_apache.yml

Gather facts, while limiting to a single host

 >ansible all -m gather_facts -u ubuntu --limit 192.168.0.102

Also can use grep

 >ansible all -m gather_facts -u ubuntu --limit 192.168.0.102 | grep "ansible_distribution"

install_apache.yml (updated to include centos)

 ---
 
 - hosts: all
   become: true
   tasks:
 
   - name: update repository index
     apt:
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
   - name: install apache2 package
     apt:
       name: apache2
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: add php support for apache
     apt:
       name: libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: update repository index
     dnf:
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install httpd package
     dnf:
       name: httpd
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: add php support for apache
     dnf:
       name: php
       state: latest
     when: ansible_distribution == "CentOS"

CentOS doesn't open the port or start up httpd automatically, need to add other things to automate, 

```

## Improving the Ansible playbook

```yml

install_apache.yml (condensed)
 ---
 
 - hosts: all
   become: true
   tasks:
 
   - name: update repository index
     apt:
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
   - name: install apache2 and php packages for Ubuntu
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: update repository index
     dnf:
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install apache and php packages for CentOS
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"
   
install_apache.yml (further condensed)
 ---
 
 - hosts: all
   become: true
   tasks:
 
   - name: install apache2 package
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
   - name: install httpd package
     dnf:
       name:
         - httpd
         - php
       state: latest
       update_cache: yes
     when: ansible_distribution == "CentOS"


install_apache.yml (condensed even further)
 ---
 
 - hosts: all
   become: true
   tasks:
 
   - name: install apache and php
     package: 
       name:
         - "Template:Apache package"
         - "Template:Php package"
       state: latest
       update_cache: yes

/////////////////////

inventory file (with host variables added)

172.16.250.132 apache_package=apache2 php_package=libapache2-mod-php
172.16.250.133 apache_package=apache2 php_package=libapache2-mod-php
172.16.250.134 apache_package=apache2 php_package=libapache2-mod-php
172.16.250.248 apache_package=httpd php_package=php

Adding these as variables then using later in the playbook itself
```
## Targeting specific nodes

```yml

\\inventory (updated with groups)

[web_servers]
172.16.250.132
172.16.250.248
 
[db_servers]
172.16.250.133

[file_servers]
172.16.250.134



site.yml
 ---
 
 - hosts: all
   become: true
   tasks:
 
   - name: install updates (CentOS)
     dnf:
       update_only: yes
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install updates (Ubuntu)
     apt:
       upgrade: dist
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install apache and php for Ubuntu servers
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: install apache and php for CentOS servers
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"

pre_tasks mandate things happen before other plays

site.yml (second version)
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: install updates (CentOS)
     dnf:
       update_only: yes
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install updates (Ubuntu)
     apt:
       upgrade: dist
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install apache2 package
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: install httpd package
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"


site.yml (third version)
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: install updates (CentOS)
     dnf:
       update_only: yes
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install updates (Ubuntu)
     apt:
       upgrade: dist
       update_cache: yes
    when: ansible_distribution == "Ubuntu"
 
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install httpd package (CentOS)
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install apache2 package (Ubuntu)
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: db_servers
   become: true
   tasks:
 
   - name: install httpd package (CentOS)
     dnf:
       name: mariadb
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install mariadb server
     apt:
       name: mariadb-server
       state: latest
     when: ansible_distribution == "Ubuntu"


site.yml (fourth version)
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: install updates (CentOS)
     dnf:
       update_only: yes
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install updates (Ubuntu)
     apt:
       upgrade: dist
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install httpd package (CentOS)
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install apache2 package (Ubuntu)
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: db_servers
   become: true
   tasks:
 
   - name: install mariadb server package (CentOS)
     dnf:
       name: mariadb
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install mariadb server
     apt:
       name: mariadb-server
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: file_servers
   become: true
   tasks:
 
   - name: install samba package
     package:
       name: samba
       state: latest

```

## Ansible Tags

```yml

SSH into the Rapberry Pis to get the info of the model
>cat /proc/cpuinfo
also
>cat /sys/firmware/devicetree/base/model
>cat /proc/device-tree/model
Need to make a ansible playbook for it

site.yml (with tags added)
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: install updates (CentOS)
     tags: always
     dnf:
       update_only: yes
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install updates (Ubuntu)
     tags: always
     apt:
       upgrade: dist
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install httpd package (CentOS)
     tags: apache,centos,httpd
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install apache2 package (Ubuntu)
     tags: apache,apache2,ubuntu
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: db_servers
   become: true
   tasks:
 
   - name: install mariadb server package (CentOS)
     tags: centos,db,mariadb
     dnf:
       name: mariadb
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install mariadb server
     tags: db,mariadb,ubuntu
     apt:
       name: mariadb-server
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: file_servers
   tags: samba
   become: true
   tasks:
 
   - name: install samba package
     tags: samba
     package:
       name: samba
       state: latest

List the available tags in a playbook

>ansible-playbook --list-tags site_with_tags.yml

Examples of running a playbook but targeting specific tags

ansible-playbook --tags db --ask-become-pass site_with_tags.yml
>ansible-playbook --tags centos --ask-become-pass site_with_tags.yml
>ansible-playbook --tags apache --ask-become-pass site_with_tags.yml

tags a specific way of calling tags, set on actions themselves in a playbook. Not the same as the inventory usage of groups. both can be used concurrently

```

## Managing Files with Ansible

```html

default_site.html

Note: Store this file in a directory named “files” in the root of the repository.

<html>
     <title>Web-site test</title>
     <body>
        Ansible is awesome!
    </body>
</html>

```

~/.ssh/config
touch ~/.ssh/config
vim ~/.ssh/config

Host *
  AddKeysToAgent yes
  IdentityFile ~/.ssh/githubansible
  UseKeychain yes #optional

ssh-add ~/.ssh/githubansible

ssh- -T git@github.com

```yml

site.yml (updated to copy default_site.html)
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: install updates (CentOS)
     tags: always
     dnf:
       update_only: yes
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install updates (Ubuntu)
     tags: always
     apt:
       upgrade: dist
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install httpd package (CentOS)
     tags: apache,centos,httpd
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install apache2 package (Ubuntu)
     tags: apache,apache2,ubuntu
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: copy html file for site
     tags: apache,apache,apache2,httpd
     copy:
       src: default_site.html
       dest: /var/www/html/index.html #file name does not to be the same as the one of the source, able to make file in dest hidden by adding period before
       owner: root
       group: root
       mode: 0644
 #directory name of (files) is assumed
 - hosts: db_servers
   become: true
   tasks:
 
   - name: install mariadb server package (CentOS)
     tags: centos,db,mariadb
     dnf:
       name: mariadb
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install mariadb server
     tags: db,mariadb,ubuntu
     apt:
       name: mariadb-server
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: file_servers
   tags: samba
   become: true
   tasks:
 
   - name: install samba package
     tags: samba
     package:
       name: samba
       state: latest

Run the playbook

>ansible-playbook --ask-become-pass file_management.yml -u ubuntu

file_management.yml (updated)
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: install updates (CentOS)
     tags: always
     dnf:
       update_only: yes
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install updates (Ubuntu)
     tags: always
     apt:
       upgrade: dist
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
 #get the tool unzip and unzip terraform
 #needs to add section for workstations in inventory file
 #use ansible to provision your local workstation itself, your own localmachine IP
 - hosts: workstations
   become: true
   tasks:

   - name: install unzip
     package:
       name: unzip
 
   - name: install terraform
     unarchive:
      src: https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip
       dest: /usr/local/bin
       remote_src: yes
       mode: 0755
       owner: root
       group: root
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install httpd package (CentOS)
     tags: apache,centos,httpd
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install apache2 package (Ubuntu)
     tags: apache,apache2,ubuntu
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: copy html file for site
     tags: apache,apache,apache2,httpd
     copy:
       src: default_site.html
       dest: /var/www/html/index.html
       owner: root
       group: root
       mode: 0644
 
 - hosts: db_servers
   become: true
   tasks:
 
   - name: install mariadb server package (CentOS)
     tags: centos,db,mariadb
     dnf:
       name: mariadb
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install mariadb server
     tags: db,mariadb,ubuntu
     apt:
       name: mariadb-server
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: file_servers
   tags: samba
   become: true
   tasks:
 
   - name: install samba package
     tags: samba
     package:
       name: samba
       state: latest

Run the updated playbook
>ansible-playbook --ask-become-pass file_management.yml

vim instructions, useful
------------------------

```txt

:tabedit {file} in vim to open other file in a tab
vim -p {file1} {file2} to open both automatically in tabs
type [gt] ot [gT] in command mode to switch tabs
:vsplit :vsto open up multiple files in vertical split mode
:split :sp split works too
CTRL + W c to quit the window
:10sp {file} opens the file 10 lines high split
CTRL + W and CAPITAL R, swaps the splits
set splitbelow splitright = in bashrc appear below and right first
:resize + {num}, pain in focus will grow in 5, -5 will subtract
:res +/- {num} works too
:vs|:terminal opens a terminal in vim

:{file_path/file1} to open that file in :vsplit

:mksession filename.vim saves workspace > vim -S {filename.vim}
.vimrc allow set spell to use spell check
:set spelllang= {iso language codes} for specific language spell check
:resize + 5, pain in focus will grow in 5

f CTRL + N to complete to the languages next likeliest word
f CRTL + P to look for words you've already typed in the file

:Explore for files searching
:Hex | :Sex | :Lex are all file explorers, :Lex opens file explorer on the right instead

Selecting multiple lines to type on
visal block mode CTRL + V, 10j is line, Capital I, type in word, hit escape to paste to the word to all line
a to append text , 10j, type in word, hit escape to append to all ends

normal mode, press q then letter to record macro on

\\For resizing on ubuntu
root@util:~# vgdisplay
root@util:~# lvextend -l +100%FREE /dev/mapper/ubuntu--vg-ubuntu--lv
root@util:~# resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv

\\check open ports
ss -tl
netstat -tulpn
```

## Managing Services with Ansible

```yml

site.yml (text in bold has been added since the previous version)
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: install updates (CentOS)
     tags: always
     dnf:
       update_only: yes
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install updates (Ubuntu)
     tags: always
     apt:
       upgrade: dist
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
 - hosts: workstations
   become: true
   tasks:
 
   - name: install unzip
     package:
       name: unzip
 
   - name: install terraform
     unarchive:
       src: https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip
       dest: /usr/local/bin
       remote_src: yes
       mode: 0755
       owner: root
       group: root
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install httpd package (CentOS)
     tags: apache,centos,httpd
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: start and enable httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: started
     when: ansible_distribution == "CentOS"
 
   - name: install apache2 package (Ubuntu)
     tags: apache,apache2,ubuntu
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: copy html file for site
     tags: apache,apache,apache2,httpd
     copy:
       src: default_site.html
       dest: /var/www/html/index.html
       owner: root
       group: root
       mode: 0644
 
 - hosts: db_servers
   become: true
   tasks:
 
   - name: install mariadb server package (CentOS)
     tags: centos,db,mariadb
     dnf:
       name: mariadb
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install mariadb server
     tags: db,mariadb,ubuntu
     apt:
       name: mariadb-server
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: file_servers
   tags: samba
   become: true
   tasks:
 
   - name: install samba package
     tags: samba
     package:
       name: samba
       state: latest


site.yml (second version, the change is in bold)
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: install updates (CentOS)
     tags: always
     dnf:
       update_only: yes
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install updates (Ubuntu)
     tags: always
     apt:
       upgrade: dist
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
 - hosts: workstations
   become: true
   tasks:
 
   - name: install unzip
     package:
       name: unzip
 
   - name: install terraform
     unarchive:
       src: https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip
       dest: /usr/local/bin
       remote_src: yes
       mode: 0755
       owner: root
       group: root
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install httpd package (CentOS)
     tags: apache,centos,httpd
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: start and enable httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: started
       enabled: yes #starts service on startup
     when: ansible_distribution == "CentOS"
 
   - name: install apache2 package (Ubuntu)
     tags: apache,apache2,ubuntu
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: copy html file for site
     tags: apache,apache,apache2,httpd
     copy:
       src: default_site.html
       dest: /var/www/html/index.html
       owner: root
       group: root
       mode: 0644
 
 - hosts: db_servers
   become: true
   tasks:
 
   - name: install mariadb server package (CentOS)
     tags: centos,db,mariadb
     dnf:
       name: mariadb
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install mariadb server
     tags: db,mariadb,ubuntu
     apt:
       name: mariadb-server
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: file_servers
   tags: samba
   become: true
   tasks:
 
   - name: install samba package
     tags: samba
     package:
       name: samba
       state: latest


site.yml (added ‘lineinfile’ play)
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: install updates (CentOS)
     tags: always
     dnf:
       update_only: yes
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install updates (Ubuntu)
     tags: always
     apt:
       upgrade: dist
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
 - hosts: workstations
   become: true
   tasks:
 
   - name: install unzip
     package:
       name: unzip
 
   - name: install terraform
     unarchive:
       src: https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip
       dest: /usr/local/bin
       remote_src: yes
       mode: 0755
       owner: root
       group: root
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install httpd package (CentOS)
     tags: apache,centos,httpd
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: start and enable httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: started
       enabled: yes
     when: ansible_distribution == "CentOS"
 
   - name: install apache2 package (Ubuntu)
     tags: apache,apache2,ubuntu
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: change e-mail address for admin
     tags: apache,centos,httpd
     lineinfile: #changes a line in a file,
       path: /etc/httpd/conf/httpd.conf
       regexp: '^ServerAdmin' #regex to find the line, possible you can duplicate changes every time run
       line: ServerAdmin somebody@somewhere.net
     when: ansible_distribution == "CentOS"
     register: httpd #allows ansible to capture state in a variable
 
   - name: restart httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: restarted
     when: httpd.changed #works on registered variable, confusingly name httpd
 
   - name: copy html file for site
     tags: apache,apache,apache2,httpd
     copy:
       src: default_site.html
       dest: /var/www/html/index.html
       owner: root
       group: root
       mode: 0644
 
 - hosts: db_servers
   become: true
   tasks:
 
   - name: install mariadb server package (CentOS)
     tags: centos,db,mariadb
     dnf:
       name: mariadb
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install mariadb server
     tags: db,mariadb,ubuntu
     apt:
       name: mariadb-server
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: file_servers
   tags: samba
   become: true
   tasks:
 
   - name: install samba package
     tags: samba
     package:
       name: samba
       state: latest

:set number #add line numbers to vim
vim {filename} +{line number}
```
## Managing Users

```yml

site.yml (added section for creating user)

 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: install updates (CentOS)
     tags: always
     dnf:
       update_only: yes
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install updates (Ubuntu)
     tags: always
     apt:
       upgrade: dist
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
 - hosts: all
   become: true
   tasks:

   - name: create simone user
     tags: always
     user:
       name: simone
       groups: root
 
 - hosts: workstations
   become: true
   tasks:
 
   - name: install unzip
     package:
       name: unzip
 
   - name: install terraform
     unarchive:
       src: https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip
       dest: /usr/local/bin
       remote_src: yes
       mode: 0755
       owner: root
       group: root
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install httpd package (CentOS)
     tags: apache,centos,httpd
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: start and enable httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: started
       enabled: yes
     when: ansible_distribution == "CentOS"
 
   - name: install apache2 package (Ubuntu)
     tags: apache,apache2,ubuntu
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: change e-mail address for admin
     tags: apache,centos,httpd
     lineinfile:
       path: /etc/httpd/conf/httpd.conf
       regexp: '^ServerAdmin'
       line: ServerAdmin somebody@somewhere.net
     when: ansible_distribution == "CentOS"
     register: httpd
 
   - name: restart httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: restarted
     when: httpd.changed    
 
   - name: copy html file for site
     tags: apache,apache,apache2,httpd
     copy:
       src: default_site.html
       dest: /var/www/html/index.html
       owner: root
       group: root
       mode: 0644
 
 - hosts: db_servers
   become: true
   tasks:
 
   - name: install mariadb server package (CentOS)
     tags: centos,db,mariadb
     dnf:
       name: mariadb
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install mariadb server
     tags: db,mariadb,ubuntu
     apt:
       name: mariadb-server
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: file_servers
   tags: samba
   become: true
   tasks:
 
   - name: install samba package
     tags: samba
     package:
       name: samba
       state: latest

sudoer_simone
 
 simone ALL=(ALL) NOPASSWD: ALL

site.yml (now copies sudoer file)
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: install updates (CentOS)
     tags: always
     dnf:
       update_only: yes
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install updates (Ubuntu)
     tags: always
     apt:
       upgrade: dist
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
 - hosts: all
   become: true
   tasks:
 
   - name: create simone user
     user:
       name: simone
       groups: root
     
   - name: add ssh key for simone
     tags: always
     authorized_key:
       user: simone
       key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAe7/ofWLNBq3+fRn3UmgAizdicLs9vcS4Oj8VSOD1S/ ansible"
         
   - name: add sudoers file for simone
     tags: always
     copy:
       src: sudoer_simone
       dest: /etc/sudoers.d/simone
       owner: root
       group: root
       mode: 0440
 
 - hosts: workstations
   become: true
   tasks:
 
   - name: install unzip
     package:
       name: unzip
 
   - name: install terraform
     unarchive:
       src: https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip
       dest: /usr/local/bin
       remote_src: yes
       mode: 0755
       owner: root
       group: root
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install httpd package (CentOS)
     tags: apache,centos,httpd
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"
   
   - name: start and enable httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: started
       enabled: yes
     when: ansible_distribution == "CentOS"
 
   - name: install apache2 package (Ubuntu)
     tags: apache,apache2,ubuntu
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: change e-mail address for admin
     tags: apache,centos,httpd
     lineinfile:
       path: /etc/httpd/conf/httpd.conf
       regexp: '^ServerAdmin'
       line: ServerAdmin somebody@somewhere.net
     when: ansible_distribution == "CentOS"
     register: httpd
  
   - name: restart httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: restarted
     when: httpd.changed    
 
   - name: copy html file for site
     tags: apache,apache,apache2,httpd
     copy:
       src: default_site.html
       dest: /var/www/html/index.html
       owner: root
       group: root
       mode: 0644
 
 - hosts: db_servers
   become: true
   tasks:
 
   - name: install mariadb server package (CentOS)
     tags: centos,db,mariadb
    dnf:
       name: mariadb
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install mariadb server
     tags: db,mariadb,ubuntu
     apt:
       name: mariadb-server
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: file_servers
   tags: samba
   become: true
   tasks:
 
   - name: install samba package
     tags: samba
     package:
       name: samba
       state: latest
bootstrap.yml
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: install updates (CentOS)
     tags: always
     dnf:
       update_only: yes
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install updates (Ubuntu)
     tags: always
     apt:
       upgrade: dist
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
 - hosts: all
   become: true
   tasks:
 
   - name: create simone user
     user:
       name: simone
       groups: root
 
   - name: add ssh key for simone
     authorized_key:
       user: simone
       key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAe7/ofWLNBq3+fRn3UmgAizdicLs9vcS4Oj8VSOD1S/ ansible"
      
   - name: add sudoers file for simone
     copy:
       src: sudoer_simone
       dest: /etc/sudoers.d/simone
       owner: root
       group: root
       mode: 0440
site.yml (final version for this video)
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: update repository index (CentOS)
     tags: always
     dnf:
       update_cache: yes
     changed_when: false
     when: ansible_distribution == "CentOS"
 
   - name: update repository index (Ubuntu)
     tags: always
     apt:
       update_cache: yes
     changed_when: false
     when: ansible_distribution == "Ubuntu"
 
 - hosts: all
   become: true
   tasks:
 
   - name: add ssh key for simone
     authorized_key:
       user: simone
       key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAe7/ofWLNBq3+fRn3UmgAizdicLs9vcS4Oj8VSOD1S/ ansible"
 
 - hosts: workstations
   become: true
   tasks:
 
   - name: install unzip
     package:
       name: unzip
 
   - name: install terraform
     unarchive:
       src: https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip
       dest: /usr/local/bin
       remote_src: yes
       mode: 0755
       owner: root
       group: root
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install httpd package (CentOS)
     tags: apache,centos,httpd
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: start and enable httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: started
       enabled: yes
     when: ansible_distribution == "CentOS"
 
   - name: install apache2 package (Ubuntu)
     tags: apache,apache2,ubuntu
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: change e-mail address for admin
     tags: apache,centos,httpd
     lineinfile:
       path: /etc/httpd/conf/httpd.conf
       regexp: '^ServerAdmin'
       line: ServerAdmin somebody@somewhere.net
     when: ansible_distribution == "CentOS"
     register: httpd
 
   - name: restart httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: restarted
     when: httpd.changed    
 
   - name: copy html file for site
     tags: apache,apache,apache2,httpd
     copy:
       src: default_site.html
       dest: /var/www/html/index.html
       owner: root
       group: root
       mode: 0644
 
 - hosts: db_servers
   become: true
   tasks:
 
   - name: install mariadb server package (CentOS)
     tags: centos,db,mariadb
     dnf:
       name: mariadb
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install mariadb server
     tags: db,mariadb,ubuntu
     apt:
       name: mariadb-server
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: file_servers
   tags: samba
   become: true
   tasks:
 
   - name: install samba package
     tags: samba
     package:
       name: samba
       state: latest


```

## Managing Users

```yml

site.yml (added section for creating user)
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: install updates (CentOS)
     tags: always
     dnf:
       update_only: yes
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install updates (Ubuntu)
     tags: always
     apt:
       upgrade: dist
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
 - hosts: all
   become: true
   tasks:

   - name: create simone user
     tags: always
     user:
       name: simone
       groups: root
 
 - hosts: workstations
   become: true
   tasks:
 
   - name: install unzip
     package:
       name: unzip
 
   - name: install terraform
     unarchive:
       src: https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip
       dest: /usr/local/bin
       remote_src: yes
       mode: 0755
       owner: root
       group: root
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install httpd package (CentOS)
     tags: apache,centos,httpd
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: start and enable httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: started
       enabled: yes
     when: ansible_distribution == "CentOS"
 
   - name: install apache2 package (Ubuntu)
     tags: apache,apache2,ubuntu
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: change e-mail address for admin
     tags: apache,centos,httpd
     lineinfile:
       path: /etc/httpd/conf/httpd.conf
       regexp: '^ServerAdmin'
       line: ServerAdmin somebody@somewhere.net
     when: ansible_distribution == "CentOS"
     register: httpd
 
   - name: restart httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: restarted
     when: httpd.changed    
 
   - name: copy html file for site
     tags: apache,apache,apache2,httpd
     copy:
       src: default_site.html
       dest: /var/www/html/index.html
       owner: root
       group: root
       mode: 0644
 
 - hosts: db_servers
   become: true
   tasks:
 
   - name: install mariadb server package (CentOS)
     tags: centos,db,mariadb
     dnf:
       name: mariadb
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install mariadb server
     tags: db,mariadb,ubuntu
     apt:
       name: mariadb-server
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: file_servers
   tags: samba
   become: true
   tasks:
 
   - name: install samba package
     tags: samba
     package:
       name: samba
       state: latest

sudoer_simone
 
>simone ALL=(ALL) NOPASSWD: ALL

site.yml (now copies sudoer file)
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: install updates (CentOS)
     tags: always
     dnf:
       update_only: yes
       update_cache: yes
     when: ansible_distribution == "CentOS"
 
   - name: install updates (Ubuntu)
     tags: always
     apt:
       upgrade: dist
       update_cache: yes
     when: ansible_distribution == "Ubuntu"
 
 - hosts: all
   become: true
   tasks:
 
   - name: create simone user
     user:
       name: simone
       groups: root
     
   - name: add ssh key for simone
     tags: always
     authorized_key:
       user: simone
       key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAe7/ofWLNBq3+fRn3UmgAizdicLs9vcS4Oj8VSOD1S/ ansible"
         
   - name: add sudoers file for simone
     tags: always
     copy:
       src: sudoer_simone
       dest: /etc/sudoers.d/simone
       owner: root
       group: root
       mode: 0440
 
 - hosts: workstations
   become: true
   tasks:
 
   - name: install unzip
     package:
       name: unzip
 
   - name: install terraform
     unarchive:
       src: https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip
       dest: /usr/local/bin
       remote_src: yes
       mode: 0755
       owner: root
       group: root
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install httpd package (CentOS)
     tags: apache,centos,httpd
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"
   
   - name: start and enable httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: started
       enabled: yes
     when: ansible_distribution == "CentOS"
 
   - name: install apache2 package (Ubuntu)
     tags: apache,apache2,ubuntu
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: change e-mail address for admin
     tags: apache,centos,httpd
     lineinfile:
       path: /etc/httpd/conf/httpd.conf
       regexp: '^ServerAdmin'
       line: ServerAdmin somebody@somewhere.net
     when: ansible_distribution == "CentOS"
     register: httpd
  
   - name: restart httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: restarted
     when: httpd.changed    
 
   - name: copy html file for site
     tags: apache,apache,apache2,httpd
     copy:
       src: default_site.html
       dest: /var/www/html/index.html
       owner: root
       group: root
       mode: 0644
 
 - hosts: db_servers
   become: true
   tasks:
 
   - name: install mariadb server package (CentOS)
     tags: centos,db,mariadb
    dnf:
       name: mariadb
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install mariadb server
     tags: db,mariadb,ubuntu
     apt:
       name: mariadb-server
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: file_servers
   tags: samba
   become: true
   tasks:
 
   - name: install samba package
     tags: samba
     package:
       name: samba
       state: latest

bootstrap used to setup the server first before other yml

bootstrap.yml
 
---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: update repo cache (CentOS)
     tags: always
     dnf:
       update_cache: yes
      changed_when: false #stops update when no change has been made, cleaner output, cache always gets updated so it makes a comment
     when: ansible_distribution == "CentOS"
 
   - name: update repo cache (Ubuntu)
     tags: always
     apt:
       update_cache: yes
       changed_when: false
     when: ansible_distribution == "Ubuntu"
 
 - hosts: all
   become: true
   tasks:
 
   - name: create simone user
     user:
       name: simone
       groups: root
 
   - name: add ssh key for simone
     authorized_key:
       user: simone
       key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAe7/ofWLNBq3+fRn3UmgAizdicLs9vcS4Oj8VSOD1S/ ansible"
      
   - name: add sudoers file for simone
     copy:
       src: sudoer_simone #creates simone file in the files directory where i run ansible from. Dropped file in sudoers folder
       dest: /etc/sudoers.d/simone
       owner: root
       group: root
       mode: 0440

edit ansible.cfg file

no need to do --ask-become-pass
remote_user = simone #or whatever user set up for server

site.yml (final version for this video)
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: update repository index (CentOS)
     tags: always
     dnf:
       update_cache: yes
     changed_when: false
     when: ansible_distribution == "CentOS"
 
   - name: update repository index (Ubuntu)
     tags: always
     apt:
       update_cache: yes
     changed_when: false
     when: ansible_distribution == "Ubuntu"
 
 - hosts: all
   become: true
   tasks:
 
   - name: add ssh key for simone
     authorized_key:
       user: simone
       key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAe7/ofWLNBq3+fRn3UmgAizdicLs9vcS4Oj8VSOD1S/ ansible"
 
 - hosts: workstations
   become: true
   tasks:
 
   - name: install unzip
     package:
       name: unzip
 
   - name: install terraform
     unarchive:
       src: https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip
       dest: /usr/local/bin
       remote_src: yes
       mode: 0755
       owner: root
       group: root
 
 - hosts: web_servers
   become: true
   tasks:
 
   - name: install httpd package (CentOS)
     tags: apache,centos,httpd
     dnf:
       name:
         - httpd
         - php
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: start and enable httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: started
       enabled: yes
     when: ansible_distribution == "CentOS"
 
   - name: install apache2 package (Ubuntu)
     tags: apache,apache2,ubuntu
     apt:
       name:
         - apache2
         - libapache2-mod-php
       state: latest
     when: ansible_distribution == "Ubuntu"
 
   - name: change e-mail address for admin
     tags: apache,centos,httpd
     lineinfile:
       path: /etc/httpd/conf/httpd.conf
       regexp: '^ServerAdmin'
       line: ServerAdmin somebody@somewhere.net
     when: ansible_distribution == "CentOS"
     register: httpd
 
   - name: restart httpd (CentOS)
     tags: apache,centos,httpd
     service:
       name: httpd
       state: restarted
     when: httpd.changed    
 
   - name: copy html file for site
     tags: apache,apache,apache2,httpd
     copy:
       src: default_site.html
       dest: /var/www/html/index.html
       owner: root
       group: root
       mode: 0644
 
 - hosts: db_servers
   become: true
   tasks:
 
   - name: install mariadb server package (CentOS)
     tags: centos,db,mariadb
     dnf:
       name: mariadb
       state: latest
     when: ansible_distribution == "CentOS"
 
   - name: install mariadb server
     tags: db,mariadb,ubuntu
     apt:
       name: mariadb-server
       state: latest
     when: ansible_distribution == "Ubuntu"
 
 - hosts: file_servers
   tags: samba
   become: true
   tasks:
 
   - name: install samba package
     tags: samba
     package:
       name: samba
       state: latest

```
## Ansible Roles

```yml

site.yml (new version)
 ---
 
 - hosts: all
   become: true
   pre_tasks:
 
   - name: update repository index (CentOS)
     tags: always
     dnf:
       update_cache: yes
     changed_when: false
     when: ansible_distribution == "CentOS"
 
   - name: update repository index (Ubuntu)
     tags: always
     apt:
       update_cache: yes
     changed_when: false
     when: ansible_distribution == "Ubuntu"
 
 - hosts: all
   become: true
   roles:
     - base
    
 - hosts: workstations
   become: true
   roles:
     - workstations
 
 - hosts: web_servers
   become: true
   roles:
     - web_servers
 
 - hosts: db_servers
   become: true
   roles:
     - db_servers
 
 - hosts: file_servers
   become: true
   roles:
     - file_servers
Create a roles directory
 mkdir roles
Create a directory for each role you wish to add:
 cd roles
 mkdir base
 mkdir db_servers
 mkdir file_servers
 mkdir web_servers
 mkdir workstations
Inside each role directory, create a tasks directory
 cd <role_name>
 mkdir tasks
main.yml (base role)
Note: Use your actual key below on the last line, in place of the one you see here.

 - name: add ssh key for simone
   authorized_key:
     user: simone
     key: "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAe7/ofWLNBq3+fRn3UmgAizdicLs9vcS4Oj8VSOD1S/ ansible"
Set up required files/folders for db_servers role
 cd ..
 cd ..
 mkdir db_servers
 cd db_servers
 mkdir tasks
 cd tasks
 vim main.yml
main.yml (db_servers role)
 - name: install mariadb server package (CentOS)
   tags: centos,db,mariadb
   dnf:
     name: mariadb
     state: latest
   when: ansible_distribution == "CentOS"
 
 - name: install mariadb server
   tags: db,mariadb,ubuntu
   apt:
     name: mariadb-server
     state: latest
   when: ansible_distribution == "Ubuntu"
main.yml (file_servers role)
 - name: install samba package
   tags: samba
   package:
     name: samba
     state: latest
main.yml (workstations role)
 - name: install unzip
   package:
     name: unzip
 
 - name: install terraform
   unarchive:
     src: https://releases.hashicorp.com/terraform/0.12.28/terraform_0.12.28_linux_amd64.zip
     dest: /usr/local/bin
     remote_src: yes
     mode: 0755
     owner: root
     group: root
main.yml (web_servers role)
 - name: install httpd package (CentOS)
   tags: apache,centos,httpd
   dnf:
     name:
       - httpd
       - php
     state: latest
   when: ansible_distribution == "CentOS"
 
 - name: start and enable httpd (CentOS)
   tags: apache,centos,httpd
   service:
     name: httpd
     state: started
     enabled: yes
   when: ansible_distribution == "CentOS"
 
 - name: install apache2 package (Ubuntu)
   tags: apache,apache2,ubuntu
   apt:
     name:
       - apache2
       - libapache2-mod-php
     state: latest
   when: ansible_distribution == "Ubuntu"
 
 - name: change e-mail address for admin
   tags: apache,centos,httpd
   lineinfile:
     path: /etc/httpd/conf/httpd.conf
     regexp: '^ServerAdmin'
     line: ServerAdmin somebody@somewhere.net
   when: ansible_distribution == "CentOS"
   register: httpd
 
 - name: restart httpd (CentOS)
   tags: apache,centos,httpd
   service:
     name: httpd
     state: restarted
   when: httpd.changed    
 
 - name: copy html file for site
   tags: apache,apache,apache2,httpd
   copy:
     src: default_site.html
     dest: /var/www/html/index.html
     owner: root
     group: root
     mode: 0644

Run the new playbook
>ansible-playbook site.yml

```



## License
[MIT](https://choosealicense.com/licenses/mit/)
