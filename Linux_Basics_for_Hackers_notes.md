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

