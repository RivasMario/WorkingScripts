1 Getting Started With the Basics

1. Use the lscommand from the root (/) directory to explore the
directory structure of Linux. Move to each of the directories with
the cdcommand and run pwdto verify where you are in the directory
structure.
2. Use the whoamicommand to verify which user you are logged in as.
3. Use the locatecommand to find wordlists that can be used for
password cracking.
4. Use the catcommand to create a new file and then append to that
file. Keep in mind that >redirects input to a file and >>appends to a
file.
5. Create a new directory called hackerdirectory and create a new file in
that directory named hackedfile. Now copy that file to your /root
directory and rename it secretfile.

2 TEXT MANIPULATION

1. Navigate to /usr/share/wordlists/metasploit. This is a directory of multiple
wordlists that can be used to brute force passwords in various passwordprotected devices using Metasploit, the most popular pentesting and
hacking framework.
2. Use the catcommand to view the contents of the file passwords.lst.
3. Use the morecommand to display the file passwords.lst.
4. Use the lesscommand to view the file passwords.lst.
5. Now use the nlcommand to place line numbers on the passwords in
passwords.lst. There should be 88,396 passwords.
6. Use the tailcommand to see the last 20 passwords in passwords.lst.
7. Use the catcommand to display passwords.lst and pipe it to find all the
passwords that contain 123.

3 ANALYZING AND MANAGING NETWORKS

1. Find information on your active network interfaces.
2. Change the IP address on eth0to 192.168.1.1.
3. Change your hardware address on eth0.
4. Check whether you have any available wireless interfaces active.
5. Reset your IP address to a DHCP-assigned address.6. Find the nameserver and email server of your favorite website.
7. Add Google’s DNS server to your /etc/resolv.conf file so your system
refers to that server when it can’t resolve a domain name query with
your local DNS server.

4 ADDING AND REMOVING SOFTWARE

1. Install a new software package from the Kali repository.
2. Remove that same software package.
3. Update your repository.
4. Upgrade your software packages.
5. Select a new piece of software from github and clone it to your
system.

5 CONTROLLING FILE AND DIRECTORY PERMISSIONS

1. Select a directory and run a long listing on it. Note the permissions
on the files and directories.
2. Select a file you don’t have permission to execute and give yourself
execute permissions using the chmodcommand. Try using both the
numeral method (777) and the UGO method.
3. Choose another file and change its ownership using chown.
4. Use the findcommand to find all files with the SGIDbit set.

6 PROCESS MANAGEMENT

1. Run the pscommand with the auxoptions on your system and note
which process is first and which is last.
2. Run the topcommand and note the two processes using the greatest
amount of your resources.
3. Use the killcommand to kill the process that uses the most
resources.
4. Use the renicecommand to reduce the priority of a running process
to +19.
5. Create a script called myscanning(the content is not important) with a
text editor and then schedule it to run next Wednesday at 1 AM.

7 MANAGING USER ENVIRONMENT VARIABLES

1. View all of your environment variables with the morecommand.

env | more

2. Use the echocommand to view the HOSTNAMEvariable.

echo $HOSTNAME
3. Find a method to change the slash (/) to a backslash (\) in the fauxMicrosoft cmdPS1example (see Listing 7-2).

home_mf="${home//\\//}"

This breaks up as follows:
    // replace every
    \\ backslash
    / with
    / slash

Demonstration:

$ t='\a\b\c'; echo "${t//\\//}"
/a/b/c

4. Create a variable named MYNEWVARIABLEand put your name in it.
 MYNEWVARIABLE = "MARIO"


5. Use echo to view the contents of MYNEWVARIABLE.
 echo $MYNEWVARIABLE

6. Export MYNEWVARIABLEso that it’s available in all environments.
export $MYNEWVARIABLE

7. Use the echocommand to view the contents of the PATHvariable.
echo $PATH

8. Add your home directory to the PATHvariable so that any binaries in your home directory can be used in any directory.
PATH=$PATH:/usr/home

9. Change your PS1variable to “World’sGreatestHacker:”.

PS1="World's Greatest Hacker:"
export $PS1

8 BASH SCRIPTING

1. Create your own greeting script similar to our HelloHackersArise
script.
#! /bin/bash

greeting = "Hello Mario"
echo $greeting

2. Create a script similar to MySQLscanner.sh but design it to find
systems with Microsoft’s SQL Server database at port 1433. Call it
MSSQLscanner.

#! /bin/bash

#This script is designed to find hosts with MsSQL installed
 
nmap -sT 192.168.181.0/24 -p 1433 >/dev/null -oG MsSQLscan

cat MsSQLscan | grep open > MsSQLscan2

cat MsSQLscan2

3. Alter that MSSQLscanner script to prompt the user for a starting and
ending IP address and the port to search for. Then filter out all the
IP addresses where those ports are closed and display only those that
are open.

#! /bin/bash

echo "Enter the starting Ip Address:"
read FirstOcteIP

echo "Enter the last octet of the last IP address : "
read LastOctetIP

echo "Enter the port number you want to can for : "
read port

nmap -sT $FirstIP-$LastOcteIP -p $port > /dev/null -oG MsSQLscan

cat MsSQLscan | grep open > MsSQLscan2

cat MsSQLscan2

9 COMPRESSING AND ARCHIVING

1. Create three scripts to combine, similar to what we did in Chapter
8, Name them Linux4Hackers1, Linux4Hackers2, and
Linux4Hackers3.
touch Linux4Hackers{01..03}.sh

2. Create a tarball from these three files. Name the tarball L4H. Note
how the size of the sum of the three files changes when they are
tarred together.
tar -cvf L4H.tar Linux4Hackers1.sh Linux4Hackers2.sh Linux4Hackers3.sh

3. Compress the L4H tarball with gzip. Note how the size of the file
changes. Investigate how you can control overwriting existing files.
Now uncompress the L4H file.

gzip L4H.*
gunzip L4H.*

4. Repeat Exercise 3 using both bzip2and compress.

bzip2 L4H.*
bunzip L4H.*

compress L4H.*
uncompress L4H.*

5. Make a physical, bit-by-bit copy of one of your flash drives using the
ddcommand.

dd if=/dev/media of/roor/flashcopy bs=4096 conv=noerror

10 FILESYSTEM AND STORAGE DEVICE MANAGEMENT

1. Use the mountand umountcommands to mount and unmount your
flash drive.
2. Check the amount of disk space free on your primary hard drive.
fdisk -l
3. Check for errors on your flash drive with fsck.
fsck /dev/sdc1/media
after unmounting it
4. Use the ddcommand to copy the entire contents of one flash drive
to another, including deleted files.
 dd if=/dev/sdc1 of=/dev/sdc2 
5. Use the lsblkcommand to determine basic characteristics of your
block devices.
lsblk

11 THE LOGGING SYSTEM

1. Use the locatecommand to find all the rsyslogfiles.
locate rsyslog
2. Open the rsyslog.conf file and change your log rotation to one week.
sudo cat /etc/rsyslog.conf
3. Disable logging on your system. Investigate what is logged in the
file /var/log/syslog when you disable logging.
servicersyslogstop
4. Use the shredcommand to shred and delete all your kernlog files
shred -f -n 10 /var/log/kern.log.*

12 USING AND ABUSING SERVICES

1. Start your apache2 service through the command line.
2. Using the index.html file, create a simple website announcing your
arrival into the exciting world of hacking.
3. Start your SSH service via the command line. Now connect to your
Kali system from another system on your LAN.
4. Start your MySQL database service and change the root user
password to hackers-arise. Change to the mysqldatabase.
5. Start your PostgreSQL database service. Set it up as described in
this chapter to be used by Metasploit.

13 BECOMING SECURE AND ANONYMOUS

1. Run tracerouteto your favorite website. How many hops appear
between you and your favorite site?
2. Download and install the Tor browser. Now, browse anonymously
around the web just as you would with any other browser and see if
you notice any difference in speed.
3. Try using proxychainswith the Firefox browser to navigate to your
favorite website.
4. Explore commercial VPN services from some of the vendors listed
in this chapter. Choose one and test a free trial.
5. Open a free ProtonMail account and send a secure greeting to
occupytheweb@protonmail.com.

14 UNDERSTANDING AND INSPECTING WIRELESS NETWORKS

1. Check your network devices with ifconfig. Note any wireless
extensions.
2. Run iwconfigand note any wireless network adapters.
3. Check to see what Wi-Fi APs are in range with iwlist.
4. Check to see what Wi-Fi APs are in range with nmcli. Which do you
find more useful and intuitive, nmclior iwlist?
5. Connect to your Wi-Fi AP using nmcli.6. Bring up your Bluetooth adapter with hciconfigand scan for nearby
discoverable Bluetooth devices with hcitool.
7. Test whether those Bluetooth devices are within reachable distance
with l2ping.

15 MANAGING THE LINUX KERNEL AND LOADABLE KERNEL MODULES

1. Check the version of your kernel.
2. List the modules in your kernel.
3. Enable IP forwarding with a sysctlcommand.
4. Edit your /etc/sysctl.conf file to enable IP forwarding. Now, disable IP
forwarding.
5. Select one kernel module and learn more about it using modinfo

16 AUTOMATING TASKS WITH JOB SCHEDULING

1. Schedule your MySQLscanner.sh script to run every Wednesday at 3
PM.
2. Schedule your MySQLscanner.sh script to run every 10th day of the
month in April, June, and August.
3. Schedule your MySQLscanner.sh script to run every Tuesday
through Thursday at 10 AM.
4. Schedule your MySQLscanner.sh script to run daily at noon using the
shortcuts.
5. Update your rc.d script to run PostgreSQL every time your system
boots.
6. Download and install rcconf and add the PostgreSQL and MySQL
databases to start at bootup.

17 PYTHON SCRIPTING BASICS FOR HACKERS

1. Build the SSH banner-grabbing tool from Listing 17-5 and then
edit it to do a banner grab on port 21.
2. Rather than hardcoding the IP address into the script, edit your
banner-grabbing tool so that it prompts the user for the IP address.
3. Edit your tcp_server.py to prompt the user for the port to listen on.
4. Build the FTPcracker in Listing 17-7 and then edit it to use a
wordlist for user variable (similar what we did with the password)
rather than prompting the user for input.
5. Add an exceptclause to the banner-grabbing tool that prints “no
answer” if the port is closed.