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

//Chapter 2 Text manipulation

cat = poops out text, not like vim

head = gets the top lines of file 
add -20 for 20 lines

tail= similar to head where last lines are popped out. helpful for manuals or specific info 

nl= pops out file with line numbers to the left



//Chapter 3

//Chapter 4 Adding or removing software