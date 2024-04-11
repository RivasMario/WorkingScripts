# Wipe the disks and shutdown server

# The following variable sets a  master WDS, if you need to pick one. E.g. for one env
# we use we pick sn2gr1wds401 as the master server to hold a consolidating folder of
# output reports (we call nuggets).  Define that here:
# (Also if you forget to set it, we use it in a try catch block and since this consolidating
#  view is optional, we ignore if it is not set...  Also some env have file share issues
#  and you can not write anyway, so this is optional.)
$MASTER_WDS_hostname = "SN5AGR5WDS401"

$ScriptPath = Split-Path $MyInvocation.MyCommand.Path

$uuid = [guid](Get-WmiObject -Class Win32_ComputerSystemProduct).UUID
$serial = (Get-WmiObject -Class win32_Bios ).serialnumber

$macs = Get-WmiObject -Class Win32_NetworkAdapter | Where-Object {$_.macaddress} | ForEach-Object {$_.macaddress}

# This is the per WDS log file, we also add disk-wipe operation to a special log folder later on SN2

$logFile = Join-Path $ScriptPath "\Logs\$($uuid).txt"
$logDir = split-path $logFile
$logDirNuggets = (join-path "$logDir" "nuggets")

if (! (Test-Path "$logDir"))
{
    mkdir "$logDir" | out-null 
}

if (! (Test-Path "$logDirNuggets"))
{
    mkdir "$logDirNuggets" | out-null 
}

# These are for the special log folder "nuggets".
$Operation = 'wipe'
$dateString = $(get-date -f yyyyMMdd-HHmmss)

$CLONE_MESSAGES_OF_LOG_TO_HOST_AND_SLEEP_TO_DEBUG = $true 

<#
function Write-LogToHostDisplay
{
	param
	(
		[string]
		$Message,

		[ValidateSet("Error", "Information", "Verbose", "Debug")]
		[string]
		$Severity = "Information"
	)

	$string = "{0}`t{1}`t{2}" -f $([datetime]::Now),$Severity,$Message
	Write-Host -ForegroundColor Green $string

	Add-Content -Path $logFile -Value $string
}
#>

function Write-Log
{
	param
	(
		[string]
		$Message,

		[ValidateSet("Error", "Information", "Verbose", "Debug")]
		[string]
		$Severity
	)

	$string = "{0}`t{1}`t{2}" -f $([datetime]::Now),$Severity,$Message

    # show messages on screen
    if ($Severity -ne 'Error')
    {
	    Write-Host -ForegroundColor Green $string
       # if ($CLONE_MESSAGES_OF_LOG_TO_HOST_AND_SLEEP_TO_DEBUG) {start-sleep 1;}
    }
    else
    {
	    Write-Host -ForegroundColor Red $string
        if ($CLONE_MESSAGES_OF_LOG_TO_HOST_AND_SLEEP_TO_DEBUG) {start-sleep 3;}
    }

	Add-Content -Path $logFile -Value $string
}


if ( (hostname) -match 'WDS' )
{
   Write-Log "ERROR: wipe called on server: $(hostname) - You can not wipe disk a WDS!"
   exit 1
}

#################################################################################
## Clean all disks.
#################################################################################
$b_zero_disk = $false

if ($b_zero_disk) {
   $zero_disk_param = "all"
} else {
   $zero_disk_param = ""
}
####
# Next clean the disks, this version does not fill disk w/ 0's
# unless the above b_zero_disk is set to $true.  NOTE below we allow for
# bad argument to the clean to get fixed (at least to just clean it min) after the call
# as we have command invocations of:
#    clean $zero_disk_param
#    clean
####
$cmd_diskpartDisplaydisk = @"
list disk
select disk 0
list partition
attribute disk clear readonly
online disk
clean $zero_disk_param
clean
select disk 1
list partition
attribute disk clear readonly
online disk
clean $zero_disk_param
clean
select disk 2
list partition
attribute disk clear readonly
online disk
clean $zero_disk_param
clean
select disk 3
list partition
attribute disk clear readonly
online disk
clean $zero_disk_param
clean
select disk 4
list partition
attribute disk clear readonly
online disk
clean $zero_disk_param
clean
select disk 5
list partition
attribute disk clear readonly
online disk
clean $zero_disk_param
clean
select disk 6
list partition
attribute disk clear readonly
online disk
clean $zero_disk_param
clean
select disk 7
list partition
attribute disk clear readonly
online disk
clean $zero_disk_param
clean
select disk 8
list partition
attribute disk clear readonly
online disk
clean $zero_disk_param
clean
select disk 9
list partition
attribute disk clear readonly
online disk
clean $zero_disk_param
clean
select disk 10
list partition
attribute disk clear readonly
online disk
clean $zero_disk_param
clean
select disk 11
list partition
attribute disk clear readonly
online disk
clean $zero_disk_param
clean
exit
"@

############################################################################################################
# this version always does a simple clean (not a deep wipe/zero as that will take a long time on 8 drives)
############################################################################################################
$cmd_diskpartDisplaydisk = @"
list disk
select disk 0
list partition
attribute disk clear readonly
online disk
clean
select disk 1
list partition
attribute disk clear readonly
online disk
clean
select disk 2
list partition
attribute disk clear readonly
online disk
clean
select disk 3
list partition
attribute disk clear readonly
online disk
clean
select disk 4
list partition
attribute disk clear readonly
online disk
clean
select disk 5
list partition
attribute disk clear readonly
online disk
clean
select disk 6
list partition
attribute disk clear readonly
online disk
clean
select disk 7
list partition
attribute disk clear readonly
online disk
clean
select disk 8
list partition
attribute disk clear readonly
online disk
clean
list disk
exit
"@

Write-Log -Message "========================================================" -Severity Information  
Write-Log -Message "================================== Starting Wipe Attempt" -Severity Information  
Write-Log -Message "========================================================" -Severity Information  
$out = ($cmd_diskpartDisplaydisk | diskpart)
#$out = 'skipping ($cmd_diskpartDisplaydisk | 00-diskpart)'
$out | %  { Write-Log -Message "$_" -Severity Information  }

$out 


$physDisk = Get-PhysicalDisk |select -Property *
$physDisk | Sort-Object FriendlyName | select DeviceId,FriendlyName,SerialNumber,Size

Write-Log -Message " === DevId ===    === Disk Name ===        === Disk Serial Number ===     === Size === "  -Severity Information
$physDisk | Sort-Object FriendlyName | select DeviceId,FriendlyName,SerialNumber,Size `
    | %  { Write-Log -Message "$_" -Severity Information  }

$physDisk | Sort-Object FriendlyName | select DeviceId,FriendlyName,SerialNumber,Size `
   | out-string | %  { Write-Log -Message "$_" -Severity Information  }


Write-Log -Message "WipeDisk Complete, Checking if successful:" -Severity Information 

if ((get-partition) -eq $null)
{
    $wipeStatus = 'success'

    $outputMsg = @"
===================================
SUCCESS:
    ____  _      __      _       ___          
   / __ \(_)____/ /__   | |     / (_)___  ___ 
  / / / / / ___/ //_/   | | /| / / / __ \/ _ \
 / /_/ / (__  ) ,<      | |/ |/ / / /_/ /  __/
/_____/_/____/_/|_|     |__/|__/_/ .___/\___/ 
                                /_/           
   _____                                __
  / ___/__  _______________  __________/ /
  \__ \/ / / / ___/ ___/ _ \/ ___/ ___/ / 
 ___/ / /_/ / /__/ /__/  __(__  |__  )_/  
/____/\__,_/\___/\___/\___/____/____(_)   

Finished $(date)         $uuid
"@
    Write-Host $outputMsg
    Write-Log -Message $outputMsg -Severity Information 
}
else
{
    $wipeStatus = 'fail'

    $outputMsg = @"
=====================================
ERROR:   disk wipe failed. Please investigate.

    ____  _      __      _       ___          
   / __ \(_)____/ /__   | |     / (_)___  ___ 
  / / / / / ___/ //_/   | | /| / / / __ \/ _ \
 / /_/ / (__  ) ,<      | |/ |/ / / /_/ /  __/
/_____/_/____/_/|_|     |__/|__/_/ .___/\___/ 
                                /_/           
    ______      _ __         ____
   / ____/___ _(_) /__  ____/ / /
  / /_  / __ `/ / / _ \/ __  / / 
 / __/ / /_/ / / /  __/ /_/ /_/  
/_/    \__,_/_/_/\___/\__,_(_)

Finished $(date)         $uuid
    Disk wipe did not clear out all partitions on all these partitions/disks:
"@
     Write-Log -Message $outputMsg -Severity Information 

     get-partition | out-string | %  { Write-Log -Message "$_" -Severity Information  }
}



### Create a "nuggets" file for output status on SN2
### if possible, we do this as a best effort basis:
###
### These "nuggets" are stored on one WDS system as a central place to keep them
### We write to multiple places as sometimes windows will lock a file if multiple people
### are trying to view it.

######  This section will just write "nuggets" to the local WDS in ... \Logs\nuggets\
try
{
    
        $masterRepoNuggetLogfilename = (Join-Path $ScriptPath "\Logs\nuggets\$($uuid)_$($dateString)_OpStatus")
        $masterRepoNuggetLogfilename_txt = "$( $masterRepoNuggetLogfilename ).txt"
        $masterRepoNuggetLogfilename_xml = "$( $masterRepoNuggetLogfilename ).xml"

        ni $masterRepoNuggetLogfilename_txt  -Force  | out-null
        ni $masterRepoNuggetLogfilename_xml  -Force  | out-null
    
    $statusObject = [PSCustomObject]@{
        Hostname     = $(hostname)
        Status    = $wipeStatus
        Operation = $Operation  # e.g. 'wipe'

        # various info to help track machines
        Uuid = $uuid
        Serial = $serial
        Macs = "$($macs )"
        Date = $dateString
    }

    $statusObject | Out-String        > $masterRepoNuggetLogfilename_txt
    $statusObject | Export-CliXml -Path $masterRepoNuggetLogfilename_xml
}
catch
{
    Write-Log -Message "Error when trying to save status nugget to main log folder: $_" -Severity Information 
}

Write-Host "did nugget: try 1"


######  This will write "nuggets" of the operation and success/failed info to either \\sn2gr1wds401\imaging\Logs\yyyy\MM
######  or to the local WDS in ... \Logs\nuggets\yyyy\MM... Where above we defined e.g. $MASTER_WDS_hostname = "sn2gr1wds401"
try
{
    $masterRepoNuggetLogfilename = (join-path "\\$($MASTER_WDS_hostname)\imaging\Logs\$(get-date -f yyyy)\$(get-date -f MM)" "$($uuid)_$($dateString)_OpStatus")
    #$masterRepoNuggetLogfilename = (join-path "a:\tmp\logs\$(get-date -f yyyy)\$(get-date -f MM)" "$($uuid)_$($dateString))_OpStatus")
    $masterRepoNuggetLogfilename_txt = "$( $masterRepoNuggetLogfilename ).txt"
    $masterRepoNuggetLogfilename_xml = "$( $masterRepoNuggetLogfilename ).xml"

    ni $masterRepoNuggetLogfilename_txt  -Force  | out-null
    ni $masterRepoNuggetLogfilename_xml  -Force  | out-null

    # if sn2gr1wds401 will not be written to, then just use a nugget\yyyy\MM folder
    if (! (Test-Path $masterRepoNuggetLogfilename_xml))
    {
        $masterRepoNuggetLogfilename = (Join-Path $ScriptPath "\Logs\nuggets\$(get-date -f yyyy)\$(get-date -f MM)\$($uuid)_$($dateString)_OpStatus")
        $masterRepoNuggetLogfilename_txt = "$( $masterRepoNuggetLogfilename ).txt"
        $masterRepoNuggetLogfilename_xml = "$( $masterRepoNuggetLogfilename ).xml"

        ni $masterRepoNuggetLogfilename_txt  -Force  | out-null
        ni $masterRepoNuggetLogfilename_xml  -Force  | out-null
    }
    
    $statusObject = [PSCustomObject]@{
        Hostname     = $(hostname)
        Status    = $wipeStatus
        Operation = $Operation  # e.g. 'wipe'

        # various info to help track machines
        Uuid = $uuid
        Serial = $serial
        Macs = "$($macs )"
        Date = $dateString
    }

    $statusObject | Out-String        > $masterRepoNuggetLogfilename_txt
    $statusObject | Export-CliXml -Path $masterRepoNuggetLogfilename_xml
}
catch
{
    Write-Log -Message "Error when trying to save status nugget: $_" -Severity Information 
}
Write-Host "did nugget: try 2"

Write-Host "about to do a sleep for 1min:"
start-sleep -sec (1*60)  # delay for 1 min
Write-Host "Done sleeping;  done with WipeDisk."

start-sleep -sec (20)  # delay for another 20sec to view screen if you have a system that can do so, GZ etc

#start-sleep -sec (2*60  * 60)  # delay for 2 hours then shutdown
#stop-computer -force

exit 0
