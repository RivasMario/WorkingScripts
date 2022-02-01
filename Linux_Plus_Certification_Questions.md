# Assessment Test

1. What software package allows a Linux server to share folders and printers with Windows and Mac clients?

C. Samba
Samba allows Linux users to communicate with MAC or WIN clients.

2. Which software package allows developers to deploy applications using the exact same environment in which they were developed?

E. Docker
Allows developers to capture entire development environment for an application and deploy it into a produyction environment as a container


3. The cat -n File.txt command is entered at the command line. What will be the result?

D. The text file File.txt will be displayed along with line numbers.
The -n will display txt file with line numbers

4. Which of the following are stream editors? (Choose all that apply.)

B. sed
C. awk
D. gawk

all stream editors 

5. Which command in GRUB2 defines the location of the /boot folder to the first partition on the first hard drive on the system?

A. set root=hd(0,1)
GRUB2 identifies the hard drives starting at 0, but partitions start at 1, so the first drive on the first partition is (0,1). 

6. If you see read or write errors appear in the system log, what tool should you use to correct any bad sections of the hard drive?

C. fsck
fsck program can perform a filesystem check and repair multiplte types of filesystems on partitions. 

7. The init program is started on a Linux system and has a process ID number. What typically is that process’s ID number?

B. 1
Init program is typically started immediatley after the linux system has traversed the boot procees ID (PID) number of 1. The linux kernel has the PID number of 0. 

8. You need to determine the default target of a systemd system. Which of the following commands should you use?

E. systemctl get-default
systemctl get-default command will display a systemd's systems default target

9. The Cinnamon desktop environment uses which windows manager?

B. Muffin
The Cinnamon desktop environment uses the Muffin Windows Manager.

Mutter is windows manager for GNOME shell
Nemo is the file manager for Cinnamon
Folphin is the file manager for KDE Plasma desktop environment
LighDM is diplay manager for Cinnamon

10. Your X11 session has become hung. What keystrokes do you use to restart the session?

E. Ctrl+Alt+Backspace
CTRL+ALT+BACKSPACE will kill your X11 sessions and then restart it, putting you at the login screen (display manager).

CTRL+C sends and interrupt signal but not restart X11
CTRL+Z sends a stop signal
CTRL+Q will release a terminal a terminal thathas been paused by CTRL+S
CTRL+ALT+DELETE does different things on different desktop environment

11. What folder contains the time zone template files in Linux?

C. /usr/share/zoneinfo
Both Debian and Red hat based systems keep time zone info in /usr/share/zoneinfo folder.

/etc/timexone and /etc/localtime contain current timezone not the template files.


12. What systemd command allows you to view and change the time, date, and time zone?

A. timedatectl
timedatectl is part of systemd package and allows you to view and change current time date and timexone for linux

localectl handles localization info not time date.
date lets you see the date.
time lets you see elapsed cpu time used by app
locale allows you to view localization settings for linux.

13. Which of the following files contain user account creation directives used by the useradd command? (Choose all that apply.)

A. The /etc/default/useradd file
D. The /etc/login.defs file
Both A and D, are files that contain user account creation directives used by useradd command.


14. You need to display the various quotas on all your filesystems employing quota limits. Which of the following commands should you use?

E. repquota -a
will display various quotas on all your fiesystems employing quota limits

edquota -t will edit quota grace periods for a system.
quotaon -a will automatically turn on quotas for all mopunted non-NFS filesystems in /etc/fstab file.
The quotacheck utility creates either the aquota.group file, if the -cg options are used, or the aquota.user file, if the -cu switches are used, or both files if -cug is employed.

15. What drive and partition does the raw device file /dev/sdb1 reference?

A. The first partition on the second SCSI storage device
Linux uses the /dev/sdxx format for SCSI and SATA raw devices.The drive is represented by a letter starting with A and the partition is started with a number 1. /dev/sdb1 is second drive first partition.

16. What tool creates a logical volume from multiple physical partitions?

C. lvcreate
lvcreate program creates a logical volume from multiple partitions that you can use as a single logical device to build a filesystem and mount it to the virtual directory.

pvcreate identifies a physical volume from a partition, doesnt create logical volumes
vgcreate creates a volume group for grouping physical partitions

17. Which of the following can be used as backup utilities? (Choose all that apply.)

B. The zip utility
C. The tar utility
D. The rsync utility
E. The dd utility
ALL are acceptable to be used as backups.

gzip can be used after a backup is created or employed through tar  to compress a backup

18. A system administrator has created a backup archive and transferred the file to another system across the network. Which utilities can be used to check the archive files integrity? (Choose all that apply.)

B. The md5sum utility
E. The sha512sum utility
Both md5sum and sha512sum produce hashes on files which can be compared to determin if file corruption occured.

19. What tool should you use to install a .deb package file?

A. dpkg
The dpkg program is used for installing and removing debian based packages that us ethe .deb file format.

rpm is used for red hat based distros

20. What tool do you use to install a .rpm package file?

D. rpm

The rpm program is used for installing and removing Red Hat–based packages that use the .rpm file format

21. The lsmod utility provides the same information as what other utility or file(s)?

B. The /proc/modules file
the /proc/modules files has the same information that is displayed by the lsmod utility.

22. Which utility should be used to remove a module along with any dependent modules?
A. The rmmod utility
B. The modinfo utility
C. The cut utility
D. The depmod utility
E. The modprobe utility

23. What special bit should you set to prevent users from deleting shared files created by someone else?
A. SUID
B. GUID
C. Sticky bit
D. Read
E. Write

24. What command can you use to change the owner assigned to a file?
A. chmod
B. chown
C. chage
D. ulimit
E. chgrp

25. The directory contains the various PAM configuration files.
A. The /etc/pam/ directory
B. The /etc/pam_modules/ directory
C. The /etc/modules/ directory
D. The /etc/pam.d/ directory
E. The /etc/pam_modules.d/ directory

26. Which of the following can override the settings in the ~/.ssh/config file?
A. The settings in the /etc/ssh/ssh_config file.
B. The ssh utility’s command-line options.
C. You cannot override the settings in this file.
D. The settings in the /etc/ssh/sshd_config file.
E. The settings in the sshd daemon’s configuration file.Assessment Test xlvii

27. What command can you use to display new entries in a log file in real time as they occur?
A. head
B. tail
C. tail -f
D. head -f
E. vi

28. What command do you use to display entries in the systemd-journald journal?
A. journalctl
B. syslogd
C. klogd
D. systemd-journald
E. vi

29. The /etc/services file may be used by firewalls for what purpose?
A. To designate what remote services to block
B. To store their ACL rules
C. To map a service name to a port and protocol
D. To determine if the port can be accessed
E. To designate what local services can send out packets

30. Which of the following is true about netfilter? (Choose all that apply.)
A. It is used by firewalld
B. It is used by UFW.
C. It provides code hooks into the Linux kernel for firewall technologies to use.
D. It is used by iptables.
E. It provides firewall services without the need for other applications.

31. Which of the following is a measurement of the maximum amount of data that can be transferred over a particular network segment?
A. Bandwidth
B. Throughput
C. Saturation
D. Latency
E. Routing

32. Which tool will allow you to view disk I/O specific to swapping?
A. ipcs -m
B. cat /proc/meminfo
C. free
D. swapon -s
E. vmstatxlviii Assessment Test

33. What command-line command allows you to view the applications currently running on the Linux system?
A. lsof
B. kill
C. ps
D. w
E. nice

34. What command-line commands allow you to send process signals to running applications? (Choose two.)
A. renice
B. pkill
C. nice
D. kill
E. pgrep

35. Annika puts the file line PS1="My Prompt: " into her account’s $HOME/.bash_profile file. This setting changes her prompt the next time she logs into the system. However, when she starts a subshell, it is not working properly. What does Annika need to do to fix this issue?
A. Add the file line to the $HOME/.profile file instead.
B. Nothing. A user’s prompt cannot be changed in a subshell.
C. Add export prior to PS1 on the same line in the file.
D. Change her default shell to /bin/dash for this to work.
E. Change the last field in her password record to /sbin/false.

36. A user, who is not the owner or a group member of a particular directory, attempts to use the ls command on the directory and gets a permission error. What does this mean?
A. The directory does not have display (d) set for other permissions.
B. The directory does not have execute (x) set for other permissions.
C. The directory does not have write (w) set for other permissions.
D. The directory does not have list (l) set for other permissions.
E. The directory does not have read (r) set for other permissions.

37. Which directories contain dynamic files that display kernel and system information? (Choose two.)
A. /dev
B. /proc
C. /etc
D. /sys
E. /dev/mapperAssessment Test xlix

38. What directory contains configuration information for the X Windows System in Linux?
A. /dev
B. /proc
C. /etc/X11
D. /sys
E. /proc/interrupts

39. How would you fix a “mount point does not exist” problem?
A. Employ the fsck utility to fix the bad disk sector.
B. Employ the badblocks utility to fix the bad disk sector.
C. Use super user privileges, if needed, and create the directory via the vgchange 
command.
D. Use super user privileges, if needed, and create the directory via the mkdir command.
E. Use super user privileges, if needed, and create the directory via the mountpoint 
command.

40. Peter is trying to complete his network application, Spider, but is running into a problem with accessing a remote server’s files and there are no network problems occurring at this time. He thinks it has something to do with the remote server’s ACLs being too restrictive. You need to investigate this issue. Which of the following might you use for troubleshooting this problem? (Choose all that apply.)
A. The firewall-cmd command
B. The ufw command
C. The iptables command
D. The getacl command
E. The setacl command

41. Which Bash shell script command allows you to iterate through a series of data until the data is complete?
A. if
B. case
C. for
D. exit
E. $()

42. Which environment variable allows you to retrieve the numeric user ID value for the user account running a shell script?
A. $USER
B. $UID
C. $BASH
D. $HOME
E. $1l Assessment Test

43. What does placing an ampersand sign (&) after a command on the command-line do?
A. Disconnects the command from the console session
B. Schedules the command to run later
C. Runs the command in background mode
D. Redirects the output to another command
E. Redirects the output to a file

44. When will the cron table entry 0 0 1 * * myscript run the specified command?
A. At 1 a.m. every day
B. At midnight on the first day of every month
C. At midnight on the first day of every week
D. At 1 p.m. every day
E. At midnight every day

45. Which of the following packages will provide you with the utilities to set up Git VCS on a system?
A. git-vcs
B. GitHub
C. gitlab
D. Bitbucket
E. git

46. If you do not tack on the -m option with an argument to the git commit command, what will happen?
A. The command will throw an error message and fail.
B. The commit will take place, but no tracking will occur.
C. You are placed in an editor for the COMMIT_EDITMSG file.
D. Your commit will fail, and the file is removed from the index.
E. Nothing. This is an optional switch.

47. At a virtualization conference, you overhear someone talking about using blobs on their cloud-based virtualization service. Which virtualization service are they using?
A. Amazon Web Services
B. KVM
C. Digital Ocean
D. GitHub
E. Microsoft AzureAssessment Test li

48. “A networking method for controlling and managing network communications via software that consists of a controller program as well as two APIs” describes which of the following?
A. Thick provisioning
B. Thin provisioning
C. SDN
D. NAT
E. VLAN

49. Your company decides it needs an orchestration system (also called an engine). Which of the following is one you could choose? (Choose all that apply.)
A. Mesos
B. Kubernetes
C. Splunk
D. Swarm
E. AWS

50. Which of the following is used in container orchestration? (Choose all that apply.)
A. Automated configuration management
B. Self-healing
C. DevOps
D. Agentless monitoring
E. Build automation

51. What type of cloud service provides the full application environment so that everyone on the Internet can run it?
A. PaaS
B. Private
C. Public
D. SaaS
E. Hybrid

52. What type of hypervisor is the Oracle VirtualBox application?
A. PaaS
B. SaaS
C. Type II
D. Type I
E. Privatelii Assessment Test

53. What file should you place console and terminal file names into to prevent users from logging into the Linux system as the root user account from those locations?
A. /etc/cron.deny
B. /etc/hosts.deny
C. /etc/securetty
D. /etc/login.warn
E. /etc/motd

54. What Linux program logs user file and directory access?
A. chroot
B. LUKS
C. auditd
D. klist
E. kinit

55. You’ve moved your present working directory to a new location in the Linux virtual directory structure and need to go back to the previous directory, where you were just located. Which command should you employ?
A. cd
B. exit
C. cd ~
D. cd -
E. return

56. To copy a directory with the cp command, which option do you need to use?
A. -i
B. -R
C. -v
D. -u
E. -f