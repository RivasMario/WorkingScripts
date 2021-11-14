Get-ChildItem | Rename-Item -NewName {$_.Name -replace "[()]", ""}

Get-ChildItem -Path "C:\Users\azadmin\Calibre Library\*" -Include *.mobi -Recurse | Copy-Item -Destination "G:\My Drive\EBOOKS\MOBI"