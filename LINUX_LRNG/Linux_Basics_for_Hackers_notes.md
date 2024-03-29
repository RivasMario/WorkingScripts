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

<<<<<<< HEAD
# Special Permissions,Privilege Escalation, and the Hacker

Privilege Escalation where a regular user gains root or sysadmin privileges and associated perms, root you hyave power

SUID Bit is one avenue. sysadmin or developer might give a program access to files with root, can be used to get access top pwds at /etc/shadow

find is more powerfull than locate or which but is more complicated in syntax

find / -user root -perm -4000

in find syntax looks at the top of file system /. -user switch looks through root user, suid permission bit set -per -4000

outputs files that have suid bit set, navigate to /usr/bin

cd /usr/bin
ls -l

//Chapter  6 Process Management

Linux has tons of processes running at any time managing anything on the server, apps, databases. You should know what to manage and find process and stop some (antivirus, firewall) and set a script to run to find processes running on the host. 

Managing processes, running in background, prioritizing and killing them. And scheduling of processes to run on date/times.

<<<<<<< HEAD
=======
ps = command is the basic for finding processes 

>>>>>>> 84c9ee51b227a1141a8774bd84889cc1449db229
Unique Process ID (PID) for each process
running ps started/invoked

ps aux shows all processes running for all users.

first process is init, last process is command we ran to display ps aux

USER : The user who invoked the process
PID: The Process ID
%CPU: The percent of CPU this process is using
%MEM: The percent of memory this process is using
COMMAND: Name of command that started process

Filtering by process name: you dont want literally every process but a select few, to find the correct one we will use metasplot exploitation framework.

msfconsole

ps aux | grep msfconsole

top = command gets the greediest processes running
while in top pressing H or ? key will bring up a list of interactive commands, pressing Q will quit top

Managing Processes
Hackers run multiple jobs at the same time. Learning how to manage them is critcal

Changing Process Priority with nice

nice = uses nice to suggest to kernel priority of proceses running 
"how nice you are to other users on the system, by using or not most of the resources" 

the values range from -20 to +19, high nice value is good to other users, low nice value is not nice to others

value of process is inherited by parent process, owner/user of process can lower priority but not increase. only root/superusers can set arbitrary nice value

nice command increments value
renice wants and absolute value for niceness

nice -n -10 /bin/slowprocess
nice -n 10 /bin/slowprocess

renice = changes nice level to specific level, requires process PID

renice 20 6996

like nice any user can give a process a lower priority, only root can give it a higher priority

you can use top to change priority as well by pressing R and providing nice value with PID

ps aus | grep msfconsole

Killing Processes

zombie process = frozen or taking to many resources

kill = used to stop processes, 64 kill signals  each does something different

kill-signal PID, signal switch optional, no switch defaults to SIGTERM

SIGNAL NAME | NUMBER | DESCRIPTION

SIGHUP        1         HANGUP (HUP) Signal stops process and restarts with same PID
SIGINT        2         INTERRUPT (INT) weak kill signal, not guranteed, most cases
SIGQUIT       3         CORE DUMP stops proces saves info in memory, incurrentdirectoryto core
SIGTERM       15        TERMINATION (TERM) default kill signal
SIGKILL       9         absolute kill signal, forces to stop by sending resources to a special device /dev/null

kill -1 6996
basic restart of process

kill -9 6996
absolute kill for zombie processes

killall -9 zombieprocess

you can terminate processes in top command, Press [K] then enter PID of process

Running Processes in the Background

leafpad newscript &
and allows command to execute and a new prompt to appear

fg 1234 = fg command moves a process to the foreground with the PID

Sheduling Processes

at and crond command are for scheduling
 at command isa a daemin , background process useful for tasks in the future, diferent times

crond command is useful for recurring commands, daily, weekly

at 7:20PM
at 7:20pm June 25
at tomorrow
at now + 20 minutes

when entered at comand it goes interactive and allows you to enter a path for a script

//Chapter 7 Managing User Envrironment Variables

environment variables come in different types

shell: lowercase, only valid in shell in currently,
environment: system wide variables built into system that control way system looks acts and feels, inherited by shell or processes
variables: key value pairs, key=value1:value2, if spaces need to be in quotes

env: gets environment variables on server, always uppercase, can be created

set = gets all variables , shell local environment. will pump out an unreadable long line

set | more = a more accessible format

set | grep HITSIZE

HISTSIZE keeps past commands up to whatever the numbers are

export command vcariables

HISTSIZE = 0

echo $HISTSIZE> ~/valueofHISTSIZE.txt

set> ~/valueofALLon122521.txt

export HISTSIZE = HISTIZE set to 0 when leaving environment

HISTSIZE=1000
export HISTSIZE

first sets variable to 1000, second sets to all environments

\\CHANGING YOUR SHELL PROMPT\\

default shell in kali 

username@hostname:current_directory

if root 

root@kali:current_directory

change name in default shell by setting valie for PS1 variable, has a placeholders for information you want to display in prompt

\u name of current user
\h hostname
\w base name of current working directory
useful if shell on multiple systems, can differentiate easily

PS1 = "World's best Hacker: #"
only holds for terminal session, you need to export to make permanent

export PS1

mke it look like a windows terminal
export PS1='C:\w '

\\Changing your Path\\

PATH variable, most are located in sbin or bin, /usr/local/sbin or /usr/local/bin , if bash tries to pull a command not stored there it will bring back command not found, even if it is stored in another directory

echo $PATH = say what the PATH variable is 
/usr/local/sbin:usr/local/bin:/usr/sbin:/sbin/bin

These are the directories where your terminal will search for any command. When you enter ls, for example, the system knows to look in each of these directories for the ls command, and when it finds ls, the system executes it. Each directory is separated by a colon (:), and don’t forget to add the $content symbol to PATH.

\\Adding to the Path Variable\\

<<<<<<< HEAD
if you downloaded a new tool, you have to be in the directory to use that tool, if outside and try to use the commands it wont work because it is now in $PATH

PATH=$PATH:/root/newhackingtool

echo $PATH
/usr/local/sbin:usr/local/bin:/usr/sbin:/sbin/bin:/root/newhackingtool
shows new tool at end of string

good for directories you use often, but if you add to many it will take a while for the system to search through every one, and slow you down

\\How Not to Add to the PATH Variable\\

PATH=/root/newhackingtool
echo $PATH
/root/newhackingtool

completely wipes it
if you cd. it will say command not found, you need to append. save before apending if unsure

\\CREATING A USER-DEFINED VARIABLE\\

MYNEWVARIABLE="HACKING IS A GREAT SKILL"
assisgns string variable to MYNEWVARIABLE
echo $MYNEWVARIABLE
>HACKING IS A GREAT SKILL

think before unsetting environment variables
unset $MYNEWVARIABLE
echo $MYNEWVARIABLE
> [no return]

//Chapter 8 BASH SCRIPTING

Scripts are necessary for hacking
Ruby(metasploi exploits are wtitten in Ruby)
Python (many hacking tools are in python)
Perl (best text manipulation scripting language)

\\Crash course in Bash\\

 a shell is an interface between the user and the OS, enables you to manipulate files and run commands, utilities, programs and more.
 Korn shell, Z shell and C Shell, And Bourne-again shell = BASH
Bash is most used on all Linux distros

cd, pwd, set, umask, echo, read

vi, vim, emacs, gedit, kate, leafpad text editors
===========================================
\\First Script: "Hello, Hackers-Arise!"\\

shebang is first line indicates which interpreter you want to use for script, bash is noted by bin bash, you can do the same with python or perl in its space

#! /bin/bash

#comment
 echo "Hello, Hackers-Arise!"

save HelloHackersArise with no extention and exit text editor

ls -l

-wr-r-r--- (644)

chmod 755 HelloHackersArise (755) execute and read write permissions

ls-l
-rwx-r-x r-x
 ./HelloHackersArise to execute shell script

.\ make sit look in the current directory and not run any in another
=======================================================

\\Adding Functionality with Variables and User Input\\

#! /bin/bash

echo "What is your name?"

read name

echo "What chapter are you on in Linux Basics for Hackers?"

read chapter

echo "Welcome" $name "to Chapter" $chapter" "of Linux Basics for Hackers!"

save as WelcomeScript.sh, file will save as shell script by defaule

dont forget chmod 755 [filename]
========================================================

\\Very First Hcker Script:Scan for open ports\\

nmap = scan for open ports
nmap <type of scan> <target ip> <optionally, target port>

simplest is the TCP connect scan, designated with -sT witch in nmap. 

nmap -ST 192.168.181.1

nmap -sT 192.168.181.1 -p 3306
 
 >>A simple scanner

#! /bin/bash

#This script is designed to find hosts with MySQL installed
 
nmap -sT 192.168.181.0/24 -p 3306 >/dev/null -oG MySQLscan

cat MySQLscan | grep opem > MySQLscan2

cat MySQLscan2

save change execution and run

=============================

not just local but prompt users for ip ranges

#!/bin/bash

echo "Enter the starting Ip Address:"
read FirstOcteIP

echo "Enter the last octet of the last IP address : "
read LastOctetIP

echo "Enter the port number you want to can for : "
read port

nmap -sT $FirstIP-$LastOcteIP -p $port > /dev/null -oG MySQLscan

cat MySQLScan | grep open > MySQLscan2

cat MySQLscan2

last octet is the last 3 numbers


==============================
Built in Bash commands
CommandFunction

:           Returns 0or true
.           Executes a shell script
bg          Puts a job in the background
break       Exits the current loop
cd          Changes directory
continue    Resumes the current loop
echo        Displays the command arguments
eval        Evaluates the following expression
exec        Executes the following command without creating a new process
exit        Quits the shell
export      Makes a variable or function available to other programs
fg          Brings a job to the foreground
getopts     Parses arguments to the shell script
jobs        Lists background (bg) jobs
pwd         Displays the current directory
read        Reads a line from standard input
readonly    Declares as variable as read-only
set         Lists all variables
shift       Moves the parameters to the left
test        Evaluates arguments
[           Performs a conditional test
times       Prints the user and system times
trap        Traps a signal
type        Displays how each argument would be interpreted as a command
umask       Changes the default permissions for a new file
unset       Deletes values from a variable or function
wait        Waits for a background process to complete

\\Chapter 9 COMPRESSING AND ARCHIVING

compression mnakes data smaller, les storage easier to transit

lossy= less size of files but integrity lost, file after not exactly the same, good for graphics audio .mp3, .mp4, .png , jpg. not acceptable for files or software. 

compressing files first thing to do is send them to an archive, 

tar command, tape archive. single file from many, tarball, archive 

tar -cvf HackersArise.tar hackersarise1 hackersarise2 hackersarise3

-cvf = c means create, v verbose lists files tar is dealing with, f means write to following file.

tar uses overhead to operate and will be sum of files +, less significant size bigger files selected to convert

-t switch on tar is list content

tar -tvf hackersArise.tar

-x extract

tar -xvf HackersArise.tar

by default if extracted file already exists tar will replace it in the folder

\\Compressing Files\\

gzip, uses .tar.gz or .tgz
bzip2 uses .tar.bz2
compress uses .tar.z

compress is usually fastest but files are bigger, bzip2 slowest but smaller files, gzip in between

\\Compressing with gzip\\

gzip = GNU zip
gzip HackersArise.*

any file beginning with hackersArize and any file type

gunzip HackersArise.*
gzip can extract .zip files as well

\\Compressing with Bzip2\\

bzip2 HackersArise.*

bunzip2 HackersArise.*

\\Compressing with Compress\\

compress HackersArise.*
HackersArise.tar.Z

uncompress HackersArise.*

\\Creating Bit-by-Bit or Physical copies of Storage Devices\\

dd makes a but-by-bit copy of a file, fileystem or entire drive, even deleted files, deleted files are not copied with cp. very slow, copy without filesystem or logical structures

dd if=inputfile of=outputfile

dd if=/dev/sdb of=/root/flashcopy assumes flash is sdb
noerror continues to copy even if errors occur
bs block size =  default 512, bytes written pre block, sector size of device, most often 4kb 4096 bytes

dd if=/dev/media of=/root/flashcopy bs=4096 cov:noerror

\\Chapter 10 FILESYSTEM AND STORAGE DEVICE MANAGEMENT

no physical representation of the drive. file tree structure with / at the top.or root.

Mounting attaching drives or disks to the filesystem to make accessible to OS. hackers use external media to load data, hacking tools, even os. once on target need ways to identify 

/dev si short for device, every device on linux is represented by its own file

cdrom and cpu are noticeable. sda 1-3 sdb, sdb1. Hard drive and its partitions and thumbdrive and its partitions

\\How linux represents storage devices\\

linux uses logical labels but name smight change depending on when or where it was mounted. fpo as floppy, hda as hardrive on legacy
sda for SATA and SCSI drives number after sd is major number

<><><><><><><><><><><><><><><><><><><><><>
Device fileDescription
sda First SATA hard drive
sdb Second SATA hard drive
sdc Third SATA hard drive
sdd Fourth SATA hard drive

\\Drive Partitions\\
sda1 sda2

PartitionDescription
sda1 The first partition (1) on the first (a) SATA drive
sda2 The second (2) partition on the first (a) drive
sda3 The third (3) partition on the first (a) drive
sda4 The fourth (4) partition on the first (a) drive

fdisk -l, check partitions to see how much drive is left

swap partition acts like virtual RAM. similar to page files in windows
fdisk indicates filesystem type
High Performance File System (HPFS)
New Technology File System (NTFS)
Extended File Allocation Table (exFAT) not native to linux. but macOS and Win systems, indicates system drive was formatted on

newer system is NTFS, older is exFAT

Linux uses ext2,+ ext3, ext4 all extended filesystem. ext4 is latest

\\Character and Block Devices\\

begining at /dev might start with b or c on -l switch
two ways devices tansfers data
c = character devices interact with system by sending data like mice or keyboards.
b = block devices, sends blocks at a time. Hardrives and dvds.

\\List Block devices with lsblk\\

lsblk = list block, similar to fsdiosk -l, show devices and their partitionsno privileges to run. also shows legacy that isnt present and where they are mounted. Will show drives but also the drives and partitions in a tree. where they are mounted, just / is root /media is the media drive.

\\Mounting and Unmounting\\
most new linux distros automaount storage devices.
must be first physically attached then logically attached
mount comes from days when storage tapes had to be physically mounted ot computers. mount point where tey are attached. two main are /mnt and /media. Hard drives are usually mnt and flash are in media but can be anywhere.
 
\\Mounting Storage Devices Yourself\\
some linux distros you need to mount manually. mount point hould be an empty directory

mount /dev/sdb1 /mnt for second hard drive

mount /dev/sdc1 /media for flash drive
filesystems that are mounted are kept in a file at /etc/fstab
fstab = filesystem table, read at every boot

\\Unmounting with umount\\
eject is another word for unmount

umount /dev/sdb1
you cannot umount a busy device

\\Getting Information on Mounted Disks\\
df = disk free 

fsck = filesystem check, check filesystems for damage and repairs. or else puts bad area into bad blocks table to mark it as bad. to run fsck need to specify filesystem type.  dault is ext2. must be unmounted prior to check 

fsck -p /dev/sdb1 automatically repairs with -p

\\ Chapter 11 THE LOGGING SYSTEM

Linux uses a daemon called syslogd to autolog events variations include rsyslog and syslog-ng. Debian comes aith rsyslog

locate rsyslog

Like nearly every application in Linux, rsyslogis managed and configured by a plaintext configuration file located, as is generally the case in Linux, in the /etc directory.  /etc/rsyslog.conf

leafpad /etc/rsyslog.conf
rsyslog rules determine what kind of information is logged. 
logging rules are broken up as facility.priority action

facility is the program, priority determines what kind of messages are logged, the action determines where logs are sent

The following is a list of valid codes that can be used in place of the facilitykeyword in our configuration file rules:

auth/authpriv:  Security/authorization messages
cron:           Clock daemons
daemon:         Other daemonskernKernel messages
lpr:            Printing system
mail:           Mail system
user:           Generic user­level messages

An asterisk wildcard (*) in place of a word refers to all facilities. You can select more than one facility by listing them separated by a comma.

Here’s the full list of valid codes for priority:
debug
info
notice
warning
warn
error
err
crit
alert
emerg
panic

* is all of them 

action is usually a filename

mail.* /var/log/mail
kern.crit /.var/log/kernel
*.emerg *

logs take up space and if not deleted will take up entire Hardrive, logrotat to determine balance

Log rotation is archiving logs somewhere else and leaving new ones and auto deleting old ones after a while.

you can set with a cronjob that employs logrotate. 
leafpad /etc/logrotate.conf

weekly
rotate 4
create
compress
include /etc/logrotate.d
/var/log/wtmp {
    missingok
    monthly
    crete 0664 root utmp
    rotate 1
}

locate /var/log/auth.log.*
man logrotate

once a linux system has been infiltrated its useful to remove evidence of your actions by modifying logs

\\Deleting log files\\

shred --help
shred deletes then overwrites 4 times
-f option allow overwriting if a permission change is necessary
-n option lets you choose how many times to overwrite

shred -f -n10 /var/log/auth.log.*
-f needed to get auth to shred auth files

if you try to open they are filled with gibberish

\\Disabling logging\\

stop rsyslog daemon

service servicename start|stop|restart

service rsyslog stop

\\Chapter 12 USING AND ABUSING SERVICES

a service is an application that runs in the background waiting for you to use it. 

Apache Web Server
OpenSSH 
MySQL
PostgreSQL

some services can be stopped by GUI, sopme need command line 

service servicename start|stop|restart

service apache2 start
service apache2 stop

if you change a config file typically you need to restart for it to capture new config
service apache2 restart

cross site scriptinng (XSS)
clone a website and redirect via DNS

apt-get install apache2
LAMP PHP or Perl

services apache2 start
https://localhost/

/var/www/html/index.html is default index

sudo cat /va/www/html/index.html

phony site
after overwriting default
<html>
<body>
<h1>Hackers­Arise Is the Best! </h1>
<p> If you want to learn hacking, Hackers­Arise.com </p>
<p> is the best place to learn hacking!</p>
</body>
</html>

SSH is secure shell, replaces telnet
SSH enable sus to create an access list.authenticate users with encrypted passwords, encrypt communication. reduces chance of unwanted users usiong remote terminal. OpenSSH

Raspberry Pi Spy

service ssh start
ifconfig

ssh pi@192.168.1.101

configuring the camera
sudo raspi-config
6 Enable Camera > press enter > finish > reboot

raspistill > used to take pictures

raspistill -v -o firstpicture.jpg

-v verbose, -o filename output

databases are the golden fleece for hackers

content management systems (CMSs) Joomla, Drupal, and RubonRails us MySql

service mysql start
authenticate before logging in 
mysql -u root -p

Oracle owns MySql so a branch was created called Maria

# InteractingWithMYSQL

select      Used to retrieve data
union       Used to combine the results of two or more select operations
insert      Used to add new data
update      Used to modify existing data
delete      Used to delete dat

select user, password from customers where user='adminS';

select user, host, password from mysql.user;

show databases;

MySQL comes with three databases by default, two of which (information_schema and
performance_schema) are administrative databases that we won’t use here. mysql admin data will be used

use mysql > to enter mysql database, use -A to turn off

mysql >update user set password = PASSWORD("hackers-arise")where user = 'root';

# Accessing a remote database

mysql -u <username> -p ; is the command for localhost 

to acess a remote database you need an ip

mysql -u root -p 192.168.1.101

commands must end in a semicolon or \g

show databases;

use creditcardnumbers;

# Database Tables

show tables;

describe cardnumbers;
get veriable type,

SELECT columns FROM table

SELECT * FROM table
\\POSTGRESQL with Metasploit\\

apt-get postgres install
default database of metasploit, stores its modules and its results from scans and exploits

service postgresql start

msfconsole | to run metasploit

msf > msfdb init > then asks you to enter password

login to postgres as root
msf > su postgres

postgres@kali:/root$

postgres@kali:/root$ createuser msf_user -P

postgres@kali:/root$ createdb--owner=msf_userhackers_arise_db
postgres@kali:/root$ exit

msf >db_connectmsf_user:password@127.0.0.1/hackers_arise_db
db status

\\ Chapter 13 BECOMING SECURE AND ANONYMOUS
Methods in this Chapter
The Onion Network
Proxy servers
Virtual private networks
Private encrypted email

see what hops a packet might take between you and the destination you can use the traceroute command

traceroute ip address|domain

in 1990s US office of Naval Research (ONR) set out to develop a method for anonymously navigating the internet for espionage purposes.The Onion Router (Tor) Project 

if someone intercepts they can only see the IP of the previous hops

NSA has own Tor routers if they leave a router its even worse because thy know the destination, traffic correlation

# Proxy Servers
proxies, intermediates act as middlemen for traffic, traffic appears to come from the proxy

proxy chain
proxychains <command you want proxied> <arguments>

proxy chains nmap -sT -Pn <Ip address>

This would send the nmap–sSstealth scan command to the given IP address through a proxy. The tool then builds the chain of proxies itself, so you don’t have to worry about it.

/etc/proxychains.conf
sudo cat /etc/proxychains.conf

we will use free proxies, googlin free proxies
http://www.hidemy.name 
not to be use for real hakcing

[Proxylist]

socks4 114.134

proxy chains defaults to using TOR if no proxies are set, first through host at 127.0..0.1 on port 9050, default TOR configuration, Tor is good but slow

proxychains firefox www.hackers-arise.com

sudo cat /etc/proxychains.conf

socks4 114.134.186.12 22020
socks4 188.187.190.59 8888
socks4 181.113.121.158 335551

# Dynamic Chaining
dynamic chaining runs traffic through every proxy if one is down it goes to next proxy. 

uncomment dynaaic_chaain

# Random Chaining 

Same as Dynamic but random on list

random_chain

chain_len = 3
chooses amount form list

proxychains is only as good as the proxies you choose, hackers use paid for proxies, free proxies sell your data and history. If something is free you are not the customer, you are the product.

owner of proxy knows your identity, might be pressured by authoriteies to give up identity

\\Virtual Private Networks\\

internet device you use logs yout ip address to send info to you

\\Encrypted Email\\

google has access to unencrypted contents of email even if using HTTPS

\\ Chapter 14 UNDERSTANDING AND INSPECTING WIRELESS NETWORKS

AP (access point):  This is the device wireless users connect to for internet access
ESSID (Extendid Service Set Identifier) : multiple APs in a wireless LAN
BSSID (Basis Service set identifier): unique for every AP, same as mac address of a device
SSID (Service Set Identifier) : name of network
Channels: Wifi can opperate in 14 channels (1-14) in US limited to 1-11
Power: closer you are to AP more power
Security: Thre primary Wired Equivalent Privacy (WEP) easy cracked, Wi-fi Protected Access (WPA) a bit more secure, WPA2-PSK uses a pre shared key all users share most used
Modes: Wi-Fi can use 3 modes, managedm master or monitor
Wireles Range: broadcast at 0.5 watts, about 300 feet = 100 metershigh gain antenaes can extend up to 20 miles
Frequency: 2.4 and 5GHz

wlanX, X for number of adapters

iwconfig
managed = ready to join or has joined an AP, master ready to act or is already an ap, monitor
iwlist interface action

iwlist wlan0 scan

need MAC address of the target AP (BSSID), MAC address of a client (another Wireless network card), and the channel the AP is operating on.

nmcli (network manager command line interface) linux daemon high level interface for network interfaces is network manager

Wifi ap and their key data
nmcli dev networktype;
nmcli dev wifi
nmcli dev wifi connect AP-SSID password AP password

nmcli dev connect Hackers-Arise password 123456789
iwconfig

airmon-ng start|stop|restart interface

airmon-ng start wlan0
airodump-ng wlan0mon
airodump­ng ­c 10 ­­bssid 01:01:AA:BB:CC:22 ­w Hackers­ArisePSK wlan0mon
aireplay­ng ­­deauth 100 ­a 01:01:AA:BB:CC:22­c A0:A3:E2:44:7C:E5 wlan0mon
aircrack­ng ­w wordlist.dic ­b 01:01:AA:BB:CC:22 Hacker­ArisePSK.cap

# Bluetooth

2.4 - 2.485GHz frequency hopping 1,600 hops per second
100 meters
pairing bluetooth

Name
Class
List of services
Technical information
48­bit identifier (a MAC­like address)

apt-get install bluez

hciconfig = ifconfig for bluetooh
hcitool = inquiry tool provides name, device ID, device class, device clock info.
hdcidump = enables sniffing bluetooth 

hciconfig
hciconfig hci0 up
hcitool scan
hcitool --help
sdptool browse MACaddress
sdptool browse 76:6E:46:63:72:66
l2ping MACaddress
l2ping 76:6E:46:63:72:66 -c 4

\\Chapter 15 MANAGING THE LINUX KERNEL AND LOADABLE KERNEL MODULES

kernel = center, controls what the system does, managing memory, controlling cpu, what user sees on screen,
user land = everything else you see

kernel is protected, root or privileged accounts, kernel access is unfetted access, changes how os works
kernel module:  added ability to linux
kiadable kernel modules LKMs no reboot,
LKMs have access rootkits

uname -a

cat /proc/version
sysctl tune kernel options

sysctl -a | less

sysctl -a | less | grep ipv4
net.ipv4.ip_forward = 0
sysctl -w net.ipv4.ip_forward=1
e /etc/sysctl.conf 
lsmod

\\Chapter 16 AUTOMATING TASKS WITH JOB SCHEDULING

cron daemon or crontab run automaitcally
crond daemon runs in the back, checks cron table
/etc/crontab
seven fields in cron table
e first five are used to schedule the time
to run the task, the sixth field specifies the user, and the seventh field is used for the absolute path to the command you want to execute

the minute, hour, day of the month, month, and day of the week

FieldTime unit | Representation
1 Minute            0–59
2 Hour              0–23
3 Day of the month  1–31
4 Month             1–12
5 Day of the week   0–7

sample cron
M H DOM MON DOW USER COMMAND
30 2 * * 1­5 root /root/myscanningscript

If you want to execute a script on multiple noncontiguous days of the week, you can separate those days with commas (,). Thus, Tuesday and Thursday would be 2,4.

crontab -e
asks you your favorite text editor, usually choose nano or vim
or you can select it immediatley

leafpad /etc/crontab

backup on off hours weekend
create a user for back up
00 2 * * 0 backup /bin/systembackup.sh
1. At the top of the hour (00),
2. Of the second hour (2),
3. Of any day of the month (*),
4. Of any month (*),
5. On Sunday (0),
6. As the backup user,
7. Execute the script at /bin/systembackup.sh
The cron daemon will then execute that script every Sunday morning at 2 AM, every month

00 2 15,30 * * backup /root/systembackup.sh

00 23 * * 1­5 backup /root/systembackup.sh

This job would run at 11 PM (hour 23), every day of the month, every month, but only
on Monday through Friday (days 1–5). Especially note that we designated the days Monday through Friday by providing an interval of days (1-5) separated by a dash (-). This could have also been designated as 1,2,3,4,5; either way works perfectly fine.

\\Using crontab to Schedule Your MySQLscann\\

00 9 * * * user /usr/share/MySQLsscanner.sh

00 2 * 6­8 0,6 user /usr/share/MySQLsscanner.sh

added to cronfile

# crontab shortcuts

@yearly
@annually
@monthly
@weekly
@daily
@midnight
@noon
@reboot

@midnight user /usr/share/MySQLsscanner.sh

Whenever you start your Linux system, a number of scripts are run to set up the environment for you. These are known as the rc scripts. After the kernel has initialized and loaded all its modules, the kernel starts a daemon known as init or init.d. This daemon then begins to run a number of scripts found in /etc/init.d/rc. These scripts include commands for starting many of the services necessary to run your Linux system as you expect

Linux Runlevels

Linux has multiple runlevels that indicate what services should be started at bootup. For instance, runlevel 1 is single­user mode, and services such as networking are not started in runlevel 1. The rc scripts are set to run depending on what runlevel is selected:

0 Halt the system
1 Single­user/minimal mode
2–5 Multiuser modes
6 Reboot the system

Adding Services to rc.d
You can add services for the rc.d script to run at startup using the update-rc.d command.

update-rc.d <name of the script or service>
<remove|defaults|disable|enable>

ps aux | grep postgresql
update-rc.d postgresql defaults

\\ADDING SERVICES TO YOUR BOOTUP VIA A GUI\\

apt-get install rcconf
rcconf

In this figure, you can see the PostgreSQL service listed second from last. Press the spacebar to select this service, press TAB to highlight <Ok>, and then press ENTER. The next time you boot Kali, PostgreSQL will start automatically.



\\Chapter 17 PYTHON SCRIPTING BASICS FOR HACKERS
Many of the most popular hacker tools are written in Python, including sqlmap, scapy, the Social­Engineer Toolkit (SET), w3af, and many more

apt-get install python3-pi

pip3 install <package name>

/usr/local//lib/<python­version>/dist­packages

pip3 show pysnmp
python setup.py install for packages downloaded

https://xael.org
wget http://xael.org/norman/python/python-nmap/python-nmap-0.3.4.tar.gz

tar -xzf python-nmap-0.3.4.tar.gz
d python-nmap-.03.4/
~/python-nmap-0.3.4 >python setup.py install

Kali has the IDE PyCrust
JetBrain’s PyCharm

#! /usr/bin/python3

name="OccupyTheWeb"

print ("Greetings to " + name + " from Hackers­Arise. The Best Place to Learn Hacking!")

chmod 755 hackers-arise_greetings.py

Your current directory is not in the $PATH variable for security reasons, so we need to precede the script name with ./ to tell the system to look in the current directory for the filename and execute it.

./hackers-arise_greetings.py

#! /usr/bin/python3
HackersAriseStringVariable = "Hackers­Arise Is the Best Place to Learn Hacking"

HackersAriseIntegerVariable = 12

HackersAriseFloatingPointVariable = 3.1415

HackersAriseList = [1,2,3,4,5,6]

HackersAriseDictionary = {'name' : 'OccupyTheWeb', 'value' : 27)

print (HackersAriseStringVariable)
print (HackersAriseIntegerVariable)
print (HackersAriseFloatingPointVariable)

=====================

fruit_color = {'apple' : 'red', 'grape' : 'green', orange : 'orange'}

print (fruit_color['grape'])

fruit_color['apple'] : 'green'

chmod 755 secondpythonscript.py
./secondpythonscript.py

In Python, there is no need to declare a variable before assigning a value to it, as in some other programming languages.

==========================
Python uses the # symbol to designate the start of single­line comment. If you want to write multiline comments, you can use three double quotationmarks (""") at the start and end of the comment section.

#! /usr/bin/python3

"""
This is my first Python script with comments. Comments are used to help explain code to ourselves and fellow programmers. In this case, this simple script creates a greeting forthe user.
"""

name = "OccupyTheWeb"

print ("Greetings to "+name+" from Hackers­Arise. The Best Place to Learn Hacking!")

./hackers-arise_greetings.py

\\Funtions\\

exit() exits from a program.

float() returns its argument as a floating­point number. For example, float(1) would
return 1.0.

help() displays help on the object specified by its argument.

int() returns the integer portion of its argument (truncates).

len() returns the number of elements in a list or dictionary.

max() returns the maximum value from its argument (a list).

open() opens the file in the mode specified by its arguments.

range() returns a list of integers between two values specified by its arguments.

sorted() takes a list as an argument and returns it with its elements in order.

type() returns the type of its argument (for example, int, file, method, function)

import nmap

HackersAriseSSHBannerGrab.py

A banner is what an application presents when someone or something connects to it. It’s kind of like an application sending a greeting announcing what it is. Hackers use a technique known as banner grabbing to find out crucial information about what application or service is running on a port.


#! /usr/bin/python3
➊ import socket
➋ s = socket.socket()
➌ s.connect(("192.168.1.101", 22))
➍ answer = s.recv(1024)
➎ print (answer)
s.close

./HackersAriseSSHBannerGrab.py
SSH­2.0­OpenSSH_7.3p1 Debian­1
============================

#! /usr/bin/python3
import socket
➊ TCP_IP = "192.168.181.190"
TCP_PORT = 6996
BUFFER_SIZE = 100
➋ s = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
➌ s.bind((TCP_IP, TCP_PORT))
➍ s.listen (1)
➎ conn, addr = s.accept()
print ('Connection address: ', addr )
while 1:
data=conn.recv(BUFFER_SIZE)
 if not data:break
print ("Received data: ", data)
conn.send(data) #echo
conn.close

dict = {key1:value1, key2:value2, key3:value3...}

if conditional expression
run this code if the expression is true

if conditional expression
*** # run this code when the condition is met
else
*** # run this code when the condition is not met

count = 1
while (count <= 10):
print (count)
count += 1

for password in passwords:
attempt = connect (username, password)
if attempt == "230"
print ("Password found: " + password)
sys.exit (0)


#! /usr/bin/python3
import socket
➊ Ports = [21,22,25,3306]
➋ for i in range (0,4):
s = socket.socket()
➌ Ports = Port[i]
print ('This Is the Banner for the Port')
print (Ports)
➍ s.connect (("192.168.1.101", Port))
 answer = s.recv (1024)
print (answer)
s.close ()

#! /usr/bin/python3
import ftplib
➊ server = input(FTP Server: ")
➋ user = input("username: ")
➌ Passwordlist = input ("Path to Password List > ")
➍ try:
with open(Passwordlist, 'r') as pw:
for word in pw:
➎ word = word.strip ('\r').strip('\n')
➏ try:
ftp = ftplib.FTP(server)
ftp.login(user, word)
➐ print (Success! The password is ' + word)
➑ except:
print('still trying...')
except:
print ('Wordlist error'











