//Chapter 1 Basics

CTRL + ALT + T = Open New terminal in RDP on Kali Linux box

pwd = finding self in directory

whoami = returns the account using system currently

cd = change directory

ls  = listing contemts of directory
ls -la = all files even hidden

--help -h = getting help on any command

man = command before any command to ask for manual

locate = finds files by searching db on server updated once a day

whereis = searches  for biunary files and source and man page if possible, not just looks for the words "apple" searches for program binaries not just anything with apple in name

which = returns location of binaries in PATH variable in linux

find = looks through entire directoy
find directory options expression | find directory [FILE TYPE] -name [FOO]

* = is the wildcard operator

grep = used in piping commonly

ps = command used to find processes running on server
ps aux | grep apache2

cat = concatentate,display contents of file or make small files

> is a redirect, CTRL + D to exit, when pressed enter linux goes to interactive mode
>> double is to append
> before cat overrides the file info

touch = moving file to a new directory, also capable of renaming new file

mv = mv newfile newfile2 no rename command exists only move file, and you name it when moving

rm = removes file, exact name

rmdir = only if empty add -r to remove it and all the contents insife

rm -r [directory] removes directory in one go, very dangerous

//Chapter 2 Text manipulation]

cat = poops out text, not like vim

head = gets the top lines of file 
add -20 for 20 lines

tail= similar to head where last lines are popped out. helpful for manuals or specific info 

nl= pops out file with line numbers to the left

cat [file] | grep [syntax] = finds the files out put lines with the grep specific argument

nl [file] | grep [argument] = gets lines with argument and numbered

tail -n+507 [file] | head -n + 6 | got to line 507, get the head of the new file, 6 lines

cat [file] | grep mysql
sed s/mysql/MySQL/g [file] > file2.conf = s performs search /term to find / MySQL replacement value / g is for term globally / > then piped to a new file

sed = stream editor

sed s/mysql/MySQL/ [file] > [file].conf = replaces first occurence

sed s/mysql/MYSQL/2 [file] > [file2] replaces second instance of occurence

more [file] = displays file a page at a time

less [file] = lets you scroll through file  and filter for terms, ,ore powerful than more
"Less is more"
add forward slash to start search then put argument

//Chapter 3 Analyzing and Managing Networks

ifconfig = examining active network interfaces

iwconfig = for wireless network 

ifconfig eth0 [ipaddress] = changes static ip address

ifconfig eth0 [ipaddress] netmask 255.255.0.0 broadcast 192.168.1.255 = changes netmask and broadcast address in one action

ifconfig eth0 down
ifconfig eth0 hw ether  00:11:22:33:44:55
ifconfig eth0 up = all has to be done as once as mac address is spoofed

dhclient0 = requests a new ipaddress, because it's debian based

dig hackers-arise.com ns = gathers dns server information and ns is short for nameserver

dig [target] mx = mx switch is for targets mail servers 
BIND = Berkeley Internet Name Domain, Linux based domain name server

nano /etc/resolv.conf = set to local dns server by default

echo "nameserver 8.8.8.8" > /etc/resolv.conf = echoes string nameserver and replaces it in the file, connects to googles dns

best to local and follow it up with a public dns because the file queries them in succession

sudo nano /etc/hosts = default only contains localhost
addind 192.168.181.131[TAB]banfofamerica.com maps BOA.com to your local website. useful later for dnsspoof and ettercap

//Chapter 4 Adding and removing software

apt-cache search [argument] = checks if software package is already in repository

apt-get install [name] = fetches and installs package

apt-get remove [name] = removes install not config file

apt-get purge [name] = not only removes program but config files and their dependencies

apt-get update = gets updates for programs on system

apt-get upgrade / full-upgrade = must be root, and upgrades every package apt knows about on the system, takes time and space

repositories servers that hold distributions of linux, have different softares that are not inherent to work with other distros,
always stored in sources.list, add ubuntu repository to software package list so if not found in kali, it will look in ubuntu. Ubunut being more popular.

/etc/apt/sources.list

sudo nano /etc/apt/sources.list

distros fivide repositories into separate categories, ubuntu breaks them out as below

[main] contains supported open source software

[universe] contains community-maintained open source software

[multiverse] contains software restricted by copyright or other legal issues

[restricted] contains proprietary device drivers

[backports] contains packages from later releases

[testing,experimental,unstable] not reccomended in list

kali and ubuntu are built on debian and likely compatible
to add java find a repository with it upload to the list

GUI based software install tools no longer standard on Kali, can be added by commandline Synaptic and Gdebi

apt-get install synaptic, use the gui to find packages

using git to find community sourced projects and pulling them to your system, like bluediving a bluettoth hacking and pentesting suite

git clone https://www.github.com/balle/bluediving.git

git clone = clones repo to your system

//Chapter 5 Controlling File and Directory Permissions

Linux allows you to set limits read write and execute for particular or all users

root = controls all,
every new member is part of a logivcally designed group with appropriate permissions to complete task,  root is in root group

Permissions levels,

r to read file
w to view and edit a file
x permission to execute not specifically view or edit

chown = change owner, 
chown [user] /tmp/usersfile
provide user you want to change owner of, then the file ownership path

chgrp = changes ownership on groups
chgrp [group] newIDS

ls -l /usr/share/hashcat = checks who has the perms to folder

1 - file type
2 - permissions on the file for owner, groups , and users
3 - number of links (more advanced)
4 the owner of the file
5 - size of files in bytes
6 - when the file was created or modified last
7 - name of the file

1 - first character tells you file type [d] is directoy[-] is a file
    all 3 characters represent permisions of owner, group and all users in order
    if now letter but a dash that auth hasn't been given
    all three verions are in the same 3 letter cluster

chmod = changes permissions, only root or part of root group have this capability

linux uses binary to represent on or off 1 or 0
all creds on shows as 111, binary octal

000 0 ---
001 1 --x
010 2 -w-
011 3 -wx
100 4 r--
101 5 r-x
110 6 rw-
111 7 rwx

all owner,group and user permissions are 777 one for each

chmod 774 hashcat.hcstat

UGO = user, group, and others for permission syntax

chmod u,g,o -,+,= adding or removing perms

chmod u-w hashcat.hcstat removes write feature from users account

chmod u+x, o+x hashcat.hcstat

linux whenever anything is downloaded gives it automatic perms of 666 or 777, you need to change before you execute

chmod 766 [newtool] or chmod +x [newtool] assumes ypu mean yourself

linux automatically assigns base permissions [666] for files and [777] for directories

umask = unmask method, represents permissions on a file or dir

umask method is subtracted from permissions automaically created when creation of file or directory occurs

new files | new directories
666          777                  linux base permissions
-022         -022                 umask
644          755                  resulting permissions

umask 022 makes 666 to 644, Owner has read and write, group and other users only have read

in Debian based systems like kali umask is preconfigured to 022 meaning default for files is 644 and 755 for dir

each user can configure their umask value in <.profile> file
sudo nano /home/kaliadmin/.profile

Special permissions are for set user id (SUID) , set group id (SGID), sticky bit

users ususally need execute authority to run programs in linux but exceptions exist, like those to change your password which is stored in /etc/shadow file that houses all passwords. in such case you can grant temp auth privileges by setting [SUID] bit on the program

SUID allows any user to execute that file with owner permissions and doesn't extend past the file

SUID isn't a common task for a user but uf desited can be done by  [chmod 4644 [filename]]

SGID grants temp access to elevetated permissions for owners group, SGID bit allows someone to execute file if they belong to the same group as owner

SGID is started by 2, [chmod 2644 [filename]]

Sticky Bit = a legacy permission bit originally used in legacy UNIX systems, allows a user to delete or rename files in a directory. modern linux systems ignore it

//Chapter 6 Process Management

