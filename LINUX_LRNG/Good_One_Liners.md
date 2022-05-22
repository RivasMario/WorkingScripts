#!
sudo passwd 
sudo passwd root
sudo nano /etc/hostname
sudo nano /etc/hosts
sudo reboot 
sudo nano /etc/dhcpcd.conf

[CHANGING_LINUX_NAME]
hostnamectl
hostnamectl set-hostname {desired name}
vim /etc/hosts
vim /etc/hostname
sudo reboot

Get-ChildItem . -Attributes Directory+Hidden -ErrorAction SilentlyContinue -Filter ".git" -Recurse

find / -name ".git"


set -euo pipefail
shellcheck

https://www.shellcheck.net/
https://ninite.com
Get-ChildItem | Rename-Item -NewName {$_.Name -replace "[(]z-lib.org[])]", ""}
Get-ChildItem | Rename-Item -NewName {$_.Name -replace "[(z-lib.org)]", ""}

lsusb 

free -m

$PSScriptRoot

PacketTracer software

Get-ChildItem -Path "C:\Users\azadmin\Calibre Library\*" -Include *.mobi -Recurse | Copy-Item -Destination "G:\My Drive\EBOOKS\MOBI"

kubectl get pods | grep fdv2-6| awk '{print $1}' | while read -r line ; do kubectl exec -i $line -- powershell  -c "netsh http show sslcert hostnameport=aadcdn.msftauthimages.us:443;" </dev/null; done

echo "cd ~/Desktop/Java\ Files" >> ~/.bashrc

sudo add-apt-repository ppa:redislabs/redis
sudo apt-get update
sudo apt-get install redis

sudo apt install openjdk-8-jre

sudo update-alternatives --config x-session-manager

sudo apt-get install python3-pip
pip3 install pysnmp

sudo passwd 
sudo passwd root
sudo nano /etc/hostname
ip r | grep default
sudo nano resolv.conf
sudo nano /etc/dhcpcd.conf
hostname -I