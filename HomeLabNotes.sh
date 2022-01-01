#! /bin/bash

sdo apt-get update
sudo apt-get upgrade
sudo apt full-upgrade -y

sudo passwd 
sudo passwd root
sudo nano /etc/hostname
sudo nano /etc/hosts
sudo reboot 
sudo nano /etc/dhcpcd.conf
sudo usermod -l newUsername oldUsername
sudo usermod -d /home/newHomeDir -m newUsername

wget https://github.com/OpenMediaVault-Plugin-Developers/installScript/raw/master/install
chmod +x install
sudo bash ./install
ip address of pi nas is running OpenMediaVault

sudo apt install apt-transport-https
curl https://downloads.plex.tv/plex-keys/PlexSign.key | gpg --dearmor | sudo tee /usr/share/keyrings/plex-archive-keyring.gpg >/dev/null
echo deb [signed-by=/usr/share/keyrings/plex-archive-keyring.gpg] https://downloads.plex.tv/repo/deb public main | sudo tee /etc/apt/sources.list.d/plexmediaserver.list
sudo apt-get update
sudo apt install plexmediaserver
192.168.1.100:32400/web/