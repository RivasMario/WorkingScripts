################################################################################
##  File: Get-BladeGUIDcompareAD.ps1
##  AUTHOR: Mario Rivas
##  E-MAIL: v-mariorivas@microsoft.com
################################################################################
##
##  DEPENDENCIES: ChassisManagerModule
##                DMS/ADM Machine   
##                  
##  DESCRIPTION:  Get the Gen5 Machines to unscramble BladeGuids to UUID then get the AD,DNS,DMS pertininent information.
##
##  INPUTS:       
##                
##                
##  OUTPUTS:      None
##
##  USAGE:        Get-BladeGUIDcompareAD.ps1
##
##  NOTES: This script is useful for 
##         
##         
################################################################################
##  Revision History:
##  Date      Version   Alias       Reason for change
##  --------  -------   --------    ---------------------------------------
## 11/29/2023    1.0   v-mariorivas    Initial Release.
################################################################################
############# Initialize ##################
## DMS Login from a ADM machine inside the environment

function Test-MachineConnection {
    param (
        #[Parameter(Mandatory = $true)]
        [string]$MachineName
    )

    try {
        # Test the connection to the machine
        $pingResult = Test-Connection -ComputerName $MachineName -Count 1 -ErrorAction SilentlyContinue

        # Check if the ping was successful
        if ($null -ne $pingResult.ResponseTime) {
            #Write-Host "Ping to $MachineName successful"
            return $true
        } else {
            #Write-Host "Ping to $MachineName failed."
            return $false
        }
    } catch {
        # Catch any errors that occur during the connection test
        # Write-Host "Error: $($_.Exception.Message)"
        return $null
    }
}

function Convert-BladeGUID {
    Param([string]$BladeGuid)
    $UnscrambledGUID = $BladeGuid.ToString()
    $str = $UnscrambledGUID.split("-")
    $UUID = "$($str[4].substring(4,8))"+"-"+"$($str[4].substring(0,4))"+"-"+"$($str[3])"+"-"+"$($str[2].Substring(2,2))$($str[2].Substring(0,2))"+"-"+"$($str[1].Substring(2,2))$($str[1].Substring(0,2))$($str[0].Substring(6,2))$($str[0].Substring(4,2))$($str[0].Substring(2,2))$($str[0].Substring(0,2))"
    return $UUID
    #Write-Host "Unscrambled Netbootguid is $UUID"
}

function Resolve-UUIDByteArrayADName {
    Param([string]$UUID)
    $netbootGUIDBytes = [System.Guid]::Parse($UUID).ToByteArray()
    $MachineName = (Get-ADComputer -Filter { netbootGUID -eq $netbootGUIDBytes}).name
    return $MachineName
}

#Prestaging the hashtable
$BladeInformationArray = @()

$ChassisManagers = @(
"P20AGR5CMCA104B",
"P20AGR5CMCA104M",
"P20AGR5CMCA104T",
"P20AGR5CMCA105B",
"P20AGR5CMCA105M",
"P20AGR5CMCA105T",
"P20AGR5CMCA106B",
"P20AGR5CMCA106M",
"P20AGR5CMCA106T",
"P20AGR5CMCA108B",
"P20AGR5CMCA108M",
"P20AGR5CMCA108T",
"P20AGR5CMCA109B",
"P20AGR5CMCA109M",
"P20AGR5CMCA109T"

)

foreach ($ChassisManager in $ChassisManagers) {

24..13 | ForEach-Object{
    $BladeInformation = Get-BladeInfo -ChassisManager $ChassisManager -BladeID $_ -IncludeAdditionalInfo -ForceRefresh   
    $BladeGuid = $BladeInformation.BladeGuid
    $Power = $BladeInformation.powerstate
    $BladeID = $BladeInformation.BladeID
    $CMNAME = $BladeInformation.chassisManager
    $AssetTag = $BladeInformation.assetTag
    $SerialNumber = $BladeInformation.serialNumber
    $MacAddress = $BladeInformation.bladeMacAddressList

    $UUID = Convert-BladeGUID("$BladeGuid")
    $BladeName = Resolve-UUIDByteArrayADName("$UUID")
    $PingBoolean = if ($BladeName) { Test-MachineConnection $BladeName } else { $false }

    $BladeInformationObject = New-Object -TypeName PSObject
    $BladeInformationObject | Add-Member -Name 'BladeID' -MemberType Noteproperty -Value $BladeID
    $BladeInformationObject | Add-Member -Name 'BladeName' -MemberType Noteproperty -Value $BladeName
    $BladeInformationObject | Add-Member -Name 'UUID' -MemberType Noteproperty -Value $UUID
    $BladeInformationObject | Add-Member -Name 'PS' -MemberType Noteproperty -Value $Power
    $BladeInformationObject | Add-Member -Name 'MacAddress' -MemberType Noteproperty -Value $MacAddress
    $BladeInformationObject | Add-Member -Name 'CMNAME' -MemberType Noteproperty -Value $CMNAME
    $BladeInformationObject | Add-Member -Name 'AssetTag' -MemberType Noteproperty -Value $AssetTag
    $BladeInformationObject | Add-Member -Name 'SerialNumber' -MemberType Noteproperty -Value $SerialNumber
    $BladeInformationObject | Add-Member -Name 'Ping' -MemberType Noteproperty -Value $PingBoolean
    $BladeInformationObject | Add-Member -Name 'BladeGUID' -MemberType Noteproperty -Value $BladeGuid
    $BladeInformationArray += $BladeInformationObject
    Write-Host "Ping results for $BladeName with $UUID Ping is $PingBoolean"
}

Write-Host "CM $ChassisManager complete"

}

$BladeInformationArray | Format-Table -AutoSize


# Get the desktop path for the current user
$desktopPath = [System.IO.Path]::Combine($env:USERPROFILE, 'Desktop')

# Set the output file path
$csvFilePath = Join-Path -Path $desktopPath -ChildPath "BladeInformation.csv"

# Output the array to a CSV file on the desktop
$BladeInformationArray | Export-Csv -Path $csvFilePath -NoTypeInformation

Write-Host "CSV file created at: $csvFilePath"
