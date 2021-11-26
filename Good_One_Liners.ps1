Get-ChildItem | Rename-Item -NewName {$_.Name -replace "[(z-lib.org)]", ""}

lsusb 

free -m

$PSScriptRoot

PacketTracer software

Get-ChildItem -Path "C:\Users\azadmin\Calibre Library\*" -Include *.mobi -Recurse | Copy-Item -Destination "G:\My Drive\EBOOKS\MOBI"
