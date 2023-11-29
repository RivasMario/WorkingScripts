## DMS Login from a ADM machine inside the environment
& (Join-Path (Get-ChildItem 'C:\Program Files\DmsClientCmdLets' | Sort | select -Last 1).FullName 'grn005\DmsClientCommands.ps1')


## Chassis Manager Module import commands
Import-Module chassismanager
Set-ChassisManagerModuleConfig -UseRemotePowerShell:$False
Clear-ChassisManagerModuleCache
Set-ChassisManagerModuleConfig -IgnoreAllSSLErrors:$True -UseRemotePowerShell:$False
Clear-ChassisManagerModuleCache
Set-ChassisManagerModuleConfig -UseRemotePowerShell:$True
Clear-ChassisManagerModuleCache
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls11, [System.Net.SecurityProtocolType]::Tls
Set-ChassisManagerModuleConfig -UseRemotePowerShell:$True
Clear-ChassisManagerModuleCache

function PingMachine {
   Param([string]$machinename)
   $pingresult = Get-CimInstance win32_pingstatus -f "address='$machinename'"
   if($pingresult.statuscode -eq 0) {$true} else {$false}
}

$ChassisManager = "P20RGR5CMCA114M"
$BladeID = "23"
$Machine = "P20RGR5IDL104"

$BladeGuidsHashTable = @{}

24..13 | ForEach{
    $BladeInformation = Get-BladeInfo -ChassisManager $ChassisManager -BladeID $_ -IncludeAdditionalInfo -ForceRefresh
    $BladeGuid = $BladeInformation.BladeGuid
    $BladePowerState = $BladeInformation.powerstate
    $BladeID
    $BladeGuidsArray += "$BladeGuid"
    Write-Host "Added $BladeGuid to the array"
    }

#$UnscrambledGUIDArray = @()

ForEach ($guid in $BladeGuidsArray) {
    $UnscrambledGUID = $guid.ToString()
    $str = $UnscrambledGUID.split("-")
    $Netbootguid = "$($str[4].substring(4,8))"+"-"+"$($str[4].substring(0,4))"+"-"+"$($str[3])"+"-"+"$($str[2].Substring(2,2))$($str[2].Substring(0,2))"+"-"+"$($str[1].Substring(2,2))$($str[1].Substring(0,2))$($str[0].Substring(6,2))$($str[0].Substring(4,2))$($str[0].Substring(2,2))$($str[0].Substring(0,2))"
    $UnscrambledGUIDArray += "$Netbootguid"
    Write-Host "Unscrambled Netbootguid is $Netbootguid"
}

ForEach ($netbootGUID in $UnscrambledGUIDArray) {
    $netbootGUIDBytes = [System.Guid]::Parse($netbootGUID).ToByteArray()
    $BladeName = (Get-ADComputer -Filter { netbootGUID -eq $netbootGUIDBytes}).name
    $PingBoolean = PingMachine($BladeName)
    Write-Host "The Blade computer name is $BladeName and the ping back is $PingBoolean" 
}




PingMachine($Machine)