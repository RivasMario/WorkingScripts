ssh -i <private key path> kaliadmin@52.148.142.117

"C:\Users\V-MARIORIVAS\Work Folders\Desktop\kalilinuxlearning.pem"

ssh -i "C:\Users\V-MARIORIVAS\Work Folders\Desktop\kalilinuxlearning.pem" kaliadmin@52.148.179.65

ssh -i "C:\Users\V-MARIORIVAS\Work Folders\Desktop\KaliLinux\kalilinuxlearning.pem" "kaliadmin@"$VmIpAdress""

"G:\My Drive\kalilinuxlearning.pem"
ssh -i <private key path> kaliadmin@52.148.142.117

ssh -i "G:\My Drive\kalilinuxlearning.pem" kaliadmin@52.148.142.117

52.229.58.11

sudo apt -y install xfce4

sudo apt -y install xrdp
sudo systemctl enable xrdp
echo xfce4-session >~/.xsession
sudo service xrdp restart

sudo openvpn ~/Downloads/kaliadmin.ovpn