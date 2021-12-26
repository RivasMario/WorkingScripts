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