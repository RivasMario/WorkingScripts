#! /bin/bash

cd "H:\Folder1\Folder2\"

for /f %%i in ('dir /b *.txt') do H:\Folder1\sed.exe s/~/~\r\n/g %%i > "Y:\Folder1\Folder2\%%i" && Del %%i



