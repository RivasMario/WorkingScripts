param($StartedWithNoExit)

if (!$StartedWithNoExit) {
    powershell -noexit -file $MyInvocation.MyCommand.Path 1
    #return
}

Clear

$servern = ($env:computername)
$serverd = ($env:userdnsdomain)
$sessionid = (qwinsta ([Environment]::UserName) /server:$ServerName | foreach { (($_.trim() -replace "\s+",","))} | ConvertFrom-Csv).ID
$command = "mstsc /v:$servern.$serverd /shadow:$sessionid /control"

$output = ""
"-----------------"
$output += "`n`n"
$output += "Your FF escort is ready. You will have full control to perform your task. Sessions idle for 15 min will be disconnected. If you need to screen share with anyone, please inform me so that a ticket can be created.  Also, as a friendly reminder, do not perform any action that will expose secrets, i.e. plain text passwords, storage keys, and customer information. Please execute the following command to begin:"
$output += "`n`n"
$output += $command
$output
$output | clip.exe
"`n"
"-----------------"

"`n"
"The text above has been copied to your clipboard.  Please provide to Component Team Dev."
"`n"
