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
<#
$ChassisManagers = @(
"P20RGR5CMCA110B",
"P20RGR5CMCA110M",
"P20RGR5CMCA110T",
"P20RGR5CMCA111B",
"P20RGR5CMCA111M",
"P20RGR5CMCA111T",
"P20RGR5CMCA113B",
"P20RGR5CMCA113M",
"P20RGR5CMCA113T",
"P20RGR5CMCA114B",
"P20RGR5CMCA114M",
"P20RGR5CMCA114T",
"P20RGR5CMCA115B",
"P20RGR5CMCA115M",
"P20RGR5CMCA115T"
)

$ChassisManagers = @(
BN1GR5CMAF246B
BN1GR5CMAF246M
BN1GR5CMAF246T
BN1GR5CMAF247B
BN1GR5CMAF247M
BN1GR5CMAF247T
BN1GR5CMAF248B
BN1GR5CMAF248M
BN1GR5CMAF248T
BN1GR5CMAF249B
BN1GR5CMAF249M
BN1GR5CMAF249T
BN1GR5CMAJ219B
BN1GR5CMAJ219M
BN1GR5CMAJ219T
)

$ChassisManagers = @(
"SN5AGR5CMAY131B",
"SN5AGR5CMAY131M",
"SN5AGR5CMAY131T",
"SN5AGR5CMAY132B",
"SN5AGR5CMAY132M",
"SN5AGR5CMAY132T",
"SN5AGR5CMAY133B",
"SN5AGR5CMAY133M",
"SN5AGR5CMAY133T",
"SN5AGR5CMAY134B",
"SN5AGR5CMAY134M",
"SN5AGR5CMAY134T",
"SN5AGR5CMAY135B",
"SN5AGR5CMAY135M",
"SN5AGR5CMAY135T"
)

#>

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
    $PingBoolean = Test-MachineConnection("$BladeName")
    

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
