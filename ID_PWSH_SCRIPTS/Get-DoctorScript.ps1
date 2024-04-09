######################
#
# doctor-GetBladeInfo
#
######################
<#	.NOTES
	===========================================================================
	.DESCRIPTION
		A description tools best served by some examples:.
 
# here is a sample ChassisManager Blade Information display:
 
PS C:\Users\USER\tmp> doctor-GetBladeInfo

 
BladeID             : 19
bladeMacAddressList : 1=7C-FE-90-E2-08-B0; 2=
bladeGuid           : 3256424f-c0b2-5980-4710-00394c4c4544
bladeName           : BLADE19
powerState          : ON
bladeMacAddress     : {1, 2}
serverName          : NOT FOUND IN AD
serverDescription   : NOT FOUND IN AD
bladeNumber         : 19
completionCode      : Success
apiVersion          : 1
statusDescription   :
chassisManager      : DB3RGR1CMJ007B:8000
cachedResponse      : False
assetTag            : 7207912
biosVersion         : C1043.BS.4A16.BB1
bladeType           : Server
cpldVersion         : 013
firmwareVersion     : 01.30
hardwareVersion     : C1043H
macAddress          : {1, 2}
serialNumber        : 2VBYG92
 
If the chassis manager rotates the guid, we can reverse / convert to AD format like shown,
first lets look at some related AD guid entry by reusing a tool that builds a prestage command for us,
here we focus on the guid
 

PS C:\Users\multijit_5wn1\tmp>  Export-PrestageFromAD  MSOGRXIDLXXX
  $params = @{
    "ComputerName" = "DB3RGR1IDLDR85"
    "NetbootGuid" = [guid]"4c4c4544-0039-4710-8059-b2c04f425446"
    "NetworkAddress" = "25.144.142.29;255.255.252.0;25.144.140.1;10.112.187.94,10.112.187.95,25.144.132.254,25.144.132.255"
    "RoleName" = "2012-Gen5-IDLADR-A.1"
    "WdsServer" = "DB3RGR1WDS401"
  }
  # To prestage, (1) first verify the above, then (2) run this workflow if correct:
  # New-GenericWorkflow -WorkflowName "PrestageServerWorkflow" -WorkflowParameters $params
 
PS C:\Users\multijit_5wn1\tmp>  
 
 
That guid above, lets convert to rotated blade format:
 
==================================  Example 1
PS C:\Users\multijit_5wn1\tmp> Convert-GuidADFormatToBladeFormat "4c4c4544-0039-4710-8059-b2c04f425446"
 
Guid
----
4654424f-c0b2-5980-4710-00394c4c4544
 
 
==================================  Example 2
Next lets take what the Chassis manager gave us and convert to cononical AD format:
 
PS C:\Users\multijit_5wn1\tmp> Convert-GuidBladeFormatADFormat "3256424f-c0b2-5980-4710-00394c4c4544"
 
Guid
----
4c4c4544-0039-4710-8059-b2c04f425632
 
 
 
PS C:\Users\multijit_5wn1\tmp>  Find-GuidonAllChassisManager -ChassisManagersToSearch "DB3RGR1CMJ007B"  -p "4654424f-c0b2-5980-4710-00394c4c4" -ju
 
Scanning 1 ChassisManagers for blade
** DB3RGR1CMJ007B:
bladeGuid           : 4654424f-c0b2-5980-4710-00394c4c4544
 
 
cachedResponse      : True
 
PS C:\Users\multijit_5wn1\tmp> Find-GuidonAllChassisManager -ChassisManagersToSearch @("DB3RGR1CMJ007B","DB3RGR1CMJ007T")  -p "4654424f-c0b2-5980-4710-00394c4c4544"
 
Scanning 2 ChassisManagers for blade
** DB3RGR1CMJ007B:
 
 
chassisManager      : DB3RGR1CMJ007B:8000
serverName          : NOT FOUND IN AD
serverDescription   : NOT FOUND IN AD
bladeID             : 20
bladeGuid           : 4654424f-c0b2-5980-4710-00394c4c4544
bladeMacAddressList : 1=7C-FE-90-E2-0A-A8; 2=
powerState          : OFF
cachedResponse      : True
 
#>
 
#===================================================================================
 
<#
	.SYNOPSIS
		convert guid from active directory (AD) format into rotated "blade format"
	.DESCRIPTION
		convert guid from active directory (AD) format into rotated "blade format"
	.PARAMETER GuidString
		GUID suppled as type String.
	.EXAMPLE
		PS C:\> Convert-GuidADFormatToBladeFormat "4c4c4544-0039-4710-8059-b2c04f425446"
 
		Guid
		----
		4654424f-c0b2-5980-4710-00394c4c4544
 
	.NOTES
		See also Convert-GuidBladeFormatADFormat
 
#>
 
 
function Convert-GuidADFormatToBladeFormat
{
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[string]$GuidString
	)
	$InputGuid = [guid]"$($GuidString)"
	$InputGuidByteArray = $InputGuid.ToByteArray()
<#
#;; convert guid from AD format rotated blade format:   ((visually shows the mapping) + and - offset to make it easier to view)
68    0    79            -4
69    1    66            -3
76    2    86            -2
76    3    50            -1
57    4    178           -6
0     5    192           -5
16    6    128           -8
71    -9   89            -7
128   -8   71            -9
89    -7   16            6
178   -6   0             5
192   -5   57            4
79    -4   76            3
66    -3   76            2
84    -2   69            1
70    -1   68            0
 
 
# ;; convert guid from AD format rotated blade format:   (visually shows the mapping only positive numbers, same as above)
68    0    79            12
69    1    66            13
76    2    86            14
76    3    50            15
57    4    178           10
0     5    192           11
16    6    128           8
71    7   89             9
128   8   71             7
89    9   16             6
178   10   0             5
192   11   57            4
79    12   76            3
66    13   76            2
84    14   69            1
70    15   68            0
#>
 
	## code to implement the above mapping
	$OutputGuid = [guid]"00000000-0000-0000-0000-000000000000"
	$OutputGuidByteArray = $OutputGuid.ToByteArray()
	$ht = @{ }
	$ht.Add(0, 12);
	$ht.Add(1, 13);
	$ht.Add(2, 14);
	$ht.Add(3, 15);
	$ht.Add(4, 10);
	$ht.Add(5, 11);
	$ht.Add(6, 8);
	$ht.Add(7, 9);
	$ht.Add(8, 7);
	$ht.Add(9, 6);
	$ht.Add(10, 5);
	$ht.Add(11, 4);
	$ht.Add(12, 3);
	$ht.Add(13, 2);
	$ht.Add(14, 1);
	$ht.Add(15, 0);
	@(0 .. 15) | ForEach-Object {
		$OutputGuidByteArray[$_] = $InputGuidByteArray[$ht[$_]]
	}
	$OutputGuid = [guid]$OutputGuidByteArray
	$OutputGuid
}
 
<#
	.SYNOPSIS
		convert guid from rotated "blade format" to AD format
	.DESCRIPTION
		convert guid from rotated "blade format" to AD format
 
	
	.PARAMETER GuidString
		GUID suppled as type String.
	.EXAMPLE
				PS C:\> Convert-GuidBladeFormatADFormat -GuidString '3151424f-c0b2-5980-4710-00394c4c4544'
	.NOTES
		See also Convert-GuidADFormatToBladeFormat
#>
function Convert-GuidBladeFormatADFormat
{
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[string]$GuidString
	)
	$InputGuid = [guid]"$($GuidString)"
	$InputGuidByteArray = $InputGuid.ToByteArray()

<#
 
# ;; convert "blade rotated guid" to AD format:   (visually shows the mapping only positive numbers)
79    0        68       15
66    1        69       14
86    2        76       13
50    3        76       12
178   4        57       11
192   5        0        10
128   6        16       9
89    7        71       8
71    8        128      6
16    9        89       7
0     10       178      4
57    11       192      5
76    12       79       0
76    13       66       1
69    14       84       2
68    15       70       3
#>
	## code to implement the above mapping
 
	$OutputGuid = [guid]"00000000-0000-0000-0000-000000000000"
	$OutputGuidByteArray = $OutputGuid.ToByteArray()
	$ht = @{ }
	$ht.Add(0, 15);
	$ht.Add(1, 14);
	$ht.Add(2, 13);
	$ht.Add(3, 12);
	$ht.Add(4, 11);
	$ht.Add(5, 10);
	$ht.Add(6, 9);
	$ht.Add(7, 8);
	$ht.Add(8, 6);
	$ht.Add(9, 7);
	$ht.Add(10, 4);
	$ht.Add(11, 5);
	$ht.Add(12, 0);
	$ht.Add(13, 1);
	$ht.Add(14, 2);
	$ht.Add(15, 3);

	@(0 .. 15) | ForEach-Object {
		$OutputGuidByteArray[$_] = $InputGuidByteArray[$ht[$_]]
	}
	$OutputGuid = [guid]$OutputGuidByteArray
	$OutputGuid
}
 
 
<#
	.SYNOPSIS
		flexible findstr on blade info in ChassisManager, typically used to search the Guid field
	.DESCRIPTION
		flexible findstr on blade info in ChassisManager, typically used to search the Guid field
	.PARAMETER Chassismanager
		The Chassismanager to search for text, typically the text in the bladeGuid. Note
        if the parameter -JustGrepForString is specified we "grep" all fields including
        the GUID field.
	.PARAMETER PartOfGuid
		PartOfGuid parameter is the text to search for.
	.PARAMETER JustGrepForString
		Switch to allow  just grep for the string parameter given as parameter PartOfGuid, but, on any field!
	.EXAMPLE
				PS C:\> Find-GuidonChassisManager -Chassismanager "DB3RGR1CMJ007B"  -PartOfGuid "4544" -JustGrepForString
bladeGuid           : 3151424f-c0b2-5980-4710-00394c4c4544
bladeGuid           : 3451424f-c0b2-5980-4710-00394c4c4544
bladeGuid           : 3656424f-c0b2-5980-4710-00394c4c4544
bladeGuid           : 3551424f-c0b2-5980-4710-00394c4c4544
bladeGuid           : 3751424f-c0b2-5980-4710-00394c4c4544
bladeGuid           : 3156424f-c0b2-5980-4710-00394c4c4544
bladeGuid           : 3256424f-c0b2-5980-4710-00394c4c4544
bladeGuid           : 4654424f-c0b2-5980-4710-00394c4c4544
bladeGuid           : 3251424f-c0b2-5980-4710-00394c4c4544
bladeGuid           : 4251424f-c0b2-5980-4710-00394c4c4544
bladeGuid           : 3651424f-c0b2-5980-4710-00394c4c4544
bladeGuid           : 3351424f-c0b2-5980-4710-00394c4c4544
 
Above shows a grep output.  If we removed the -JustGrepForString it would find the matching "Blade Info" struct and return that.
 
	.NOTES
		If you add switch -JustGrepForString we can search on any field, if you do not specify we hunt only the guid field.
#>
function Find-GuidonChassisManager
{
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[string]$Chassismanager,
		[Parameter(Mandatory = $true,
				   Position = 2)]
		[string]$PartOfGuid,
		[Switch]$JustGrepForString
	)
	$chassisInfo = (Get-ChassisInfo -ChassisManager "$Chassismanager")
	if ($JustGrepForString)
	{
		($chassisInfo).bladeCollections | Out-String | findstr /i "$PartOfGuid"
	}
	else
	{
		($chassisInfo).bladeCollections | Where-Object { $_.bladeGuid -match "$PartOfGuid"; }
	}
}
 
 
<#
	.SYNOPSIS
		find all hostnames in a MSODS OU
	.DESCRIPTION
		find all hostnames in a MSODS OU
	.PARAMETER AdOuName
		Required parameter AdOuName is an OU, e.g. WDS ADR ADS ...
	.PARAMETER UseFQDN
		(OPTIONAL) Switch UseFQDN parameter specifies to output FQDN not simple hostname.
	.PARAMETER PPE
		(OPTIONAL) Switch PPE parameter, means we are running on PPE not PROD.
	.EXAMPLE
				PS C:\> Get-MsodsAdComputerNameSimple -AdOuName WDS
	.NOTES
		We only support PPE and PROD at this time.
        Some OU are special, most are simply workds like  ADS|WDS but special are:
           Domain Controllers
#>
function Get-MsodsAdComputerNameSimple
{
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1)]
		$AdOuName,
		[switch]$UseFQDN,
		[switch]$PPE
	)

 
	if ($PPE)
	{
		$DOMAIN_NAME = 'DC=grnppe,DC=msoppe,DC=msft,DC=net'
	}
	else
	{
		$DOMAIN_NAME = 'DC=GRN001,DC=msoprd,DC=msft,DC=net'
	}
	if ($AdOuName -eq 'Domain Controllers')
	{
		$ad_hosts = Get-adcomputer -filter 'name -like "*"' -SearchBase "OU=$($AdOuName),$($DOMAIN_NAME)" -properties description
	}
	else
	{
		$ad_hosts = Get-adcomputer -filter 'name -like "*"' -SearchBase "OU=$($AdOuName),OU=Server,$($DOMAIN_NAME)" -properties description
	}
	if ($UseFQDN)
	{
		$ad_hosts = $ad_hosts | ForEach-Object { $_.DNSHostName }
	}
	else
	{
		$ad_hosts = $ad_hosts | ForEach-Object { $_.Name }
	}
	$ad_hosts = $ad_hosts | Where-Object { $_ -ne $null }
	$ad_hosts
}
 
 
<#
	.SYNOPSIS
		search all CM provided to find blade matching parameters
	.DESCRIPTION
		search all CM provided to find blade matching parameters
		If switch JustGrepForString is specified we list the matching lines in the entry
		rather than a blade object
	.PARAMETER FilterDomainTo_OPTIONAL
		(OPTIONAL) parameter FilterDomainTo_OPTIONAL is given to -match to filter down the Chassismanagerstosearch
	.PARAMETER PartOfGuid
		PartOfGuid parameter is the text to search for.
	.PARAMETER JustGrepForString
		Switch to allow  just grep for some string parameter given as PartOfGuid.
	.PARAMETER ChassisManagersToSearch
		(OPTIONAL) list of  Chassis Managers to search.
	.EXAMPLE
		PS C:\> Find-GuidonAllChassisManager -PartOfGuid "4654424f-c0b2-5980-4710-00394c4c4544"
        ## should search all CM for the pattern
	.EXAMPLE
        PS C:\> Find-GuidonAllChassisManager -ChassisManagersToSearch "DB3RGR1CMJ007B"  -p "4654424f-c0b2-5980-4710-00394c4c4" -JustGrepForString
 
Scanning 1 ChassisManagers for blade
** DB3RGR1CMJ007B:
bladeGuid           : 4654424f-c0b2-5980-4710-00394c4c4544
 
 
cachedResponse      : True
 
PS C:\Users\multijit_5wn1\tmp> Find-GuidonAllChassisManager -ChassisManagersToSearch @("DB3RGR1CMJ007B","DB3RGR1CMJ007T")  -p "4654424f-c0b2-5980-4710-00394c4c4544"
 
Scanning 2 ChassisManagers for blade
** DB3RGR1CMJ007B:
 
 
chassisManager      : DB3RGR1CMJ007B:8000
serverName          : NOT FOUND IN AD
serverDescription   : NOT FOUND IN AD
bladeID             : 20
bladeGuid           : 4654424f-c0b2-5980-4710-00394c4c4544
bladeMacAddressList : 1=7C-FE-90-E2-0A-A8; 2=
powerState          : OFF
cachedResponse      : True
 
 
	.NOTES
#>
function Find-GuidonAllChassisManager
{
	param
	(
		[string]$FilterDomainTo_OPTIONAL,
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[string]$PartOfGuid,
		[Switch]$JustGrepForString,
		[string[]]$ChassisManagersToSearch
	)
	if ($ChassisManagersToSearch.count -gt 0)
	{
		$ad_CM = $ChassisManagersToSearch
	}
	else
	{
		$ad_CM = Get-MsodsAdComputerNameSimple CM
		if ("$FilterDomainTo_OPTIONAL" -ne "")
		{
			$ad_CM = $ad_CM | Where-Object { $_ -match "$FilterDomainTo_OPTIONAL"; }
		}
	}
 
	Write-Host "Scanning $($ad_CM.count) ChassisManagers for blade"
	foreach ($ChassisManager  in $ad_CM)
	{
		if ($JustGrepForString)
		{
			$out = Find-GuidonChassisManager -Chassismanager "$ChassisManager" -PartOfGuid "$PartOfGuid" -JustGrepForString
			if ("$($out)" -ne "") { Write-Output "** $($ChassisManager):"; }
			$out
		}
		else
		{
			$out = Find-GuidonChassisManager -Chassismanager "$ChassisManager" -PartOfGuid "$PartOfGuid"
			if ("$($out)" -ne "") { Write-Output "** $($ChassisManager):"; }
			$out
		}
	}
}
 
Function Get-BladeSettingsVerification ($servername){
    Write-Host "`nImage Completion Status" -ForegroundColor Cyan
    $buildLog = get-content -Path "\\$servername\C$\Build\Logs\Imaging.log" | Select-String -Pattern "imaging pass completed"
    Write-Host $buildLog

    Write-Host "`nDisk Info" -ForegroundColor Cyan
    $vd = Get-VirtualDisk -CimSession "$servername.GRN005.US.MSFT.NET" | Select-Object -Property ResiliencySettingName
    $vd.ResiliencySettingName

    Write-Host "`nHyper Threading Info" -ForegroundColor Cyan
    $ht = Get-WmiObject -ComputerName $servername -Class Win32_Processor | Select-Object -Property Name, Number*
    $cores = $ht.NumberofCores
    $lp = $ht.NumberOfLogicalProcessors
    $coresum = 0
    $lpsum = 0
    $cores | ForEach-Object{$coresum += $_}
    $lp | ForEach-Object{$lpsum += $_}
    Write-Host "Number of cores: $coresum"
    Write-Host "Number of Logical Processors: $lpsum"

    Write-Host "`nEnabled Power Plan" -ForegroundColor Cyan
    $pp = Get-WmiObject -Class win32_powerplan -Namespace root\cimv2\power -ComputerName $servername -Filter "isActive='true'" | Select-Object ElementName 
    $pp.ElementName

	$Reg = [Microsoft.Win32.RegistryKey]::OpenRemoteBaseKey('LocalMachine', $servername)
	$RegKey= $Reg.OpenSubKey("SOFTWARE\Policies\Microsoft\Cryptography\Configuration\SSL\00010002")
	$NetbackupVersion1 = $RegKey.GetValue("Functions")


    Write-Host "`nTLS Reg Settings`n" -ForegroundColor Cyan
    Write-Host "TLS CupherSuites are:`n" $NetbackupVersion1 
    
}

 
######################
#
# Prestage Helper
#
######################
 
<#	
	.NOTES
    Tools to prep for prestage
	 Created by:   	thpopovi
	===========================================================================
	.DESCRIPTION
		A description of the file.
#>
 
######################################################################################################
##  Tools to get prestage network data based on a scopeID of DHCP
######################################################################################################
 
<#
	.SYNOPSIS
		Get key Prestage Networking Info for a scopeID
	.DESCRIPTION
		A detailed description of the Get-PrestageNetworkingInfo function.
	.PARAMETER WdsComputerName
		The WdsComputerName parameter can be the WDS computer name or a shortcut like SN2
		and if not present we assume you are running on the WDS itself.
	.PARAMETER ScopeIdList
		ScopeIdList parameter can be a scopeId like "10.2.45.0" or an ipaddr "10.2.45.33"
	.EXAMPLE
		PS C:\> Get-PrestageNetworkingInfo -WdsComputerName SN2 -ScopeIdList "10.2.45.0,10.2.55.0" # lookup mulitple
		PS C:\> Get-PrestageNetworkingInfo   bl2   10.15.43.19   # detailed example 
Using WDS (BL2GR1WDS401) to look up data. 
:: data for DNS: __ 10.15.43.19 __
10.15.56.255,10.15.57.0,10.47.144.80,10.47.144.81
:: data default gateway:  __ 10.15.43.19 __
10.15.43.1
PS C:\Users\multijit_r8a1\tmp>
 
	.NOTES
#>
function Get-PrestageNetworkingInfo
{
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[string]$WdsComputerName,
		[Parameter(Mandatory = $true,
				   Position = 2)]
		[string[]]$ScopeIdList
	)
	if ("$($WdsComputerName)" -eq "")
	{
		if ("$(hostname)" -match "WDS") # if we are running on a WDS just assume to get network info on this machine
		{
			$WdsComputerName = "$(hostname)"
		}
		Write-Error "You are not running on a WDS, so must pick a wds name"
	}
	else
	{
		# see if it is a prefix and find right WDS
		$WdsFound = $(get-WDSComputernameForEnvironment $WdsComputerName)
		if ("$WdsFound" -eq '')
		{
			Write-Error "Could not find a proper WDS for $WdsComputerName " -ErrorAction Stop
		}
		else
		{
			$WdsComputerName = $WdsFound
		}
	}
	Write-Host "Using WDS ($WdsComputerName) to look up data."
	foreach ($ScopeId in $ScopeIdList)
	{
		Write-Output ":: data for DNS: __ $ScopeId __"
		$raw_val_array = ((Get-DhcpServerv4OptionValue -ComputerName $WdsComputerName -ScopeId $ScopeId -OptionId 6).value)
		# make sure we trim any spaces for safety and  comma separate
		(@($raw_val_array) | ForEach-Object { "$($_)".trim(); }) -join ","
		Write-Output ":: data default gateway:  __ $ScopeId __ "
		(Get-DhcpServerv4OptionValue -ComputerName $WdsComputerName -ScopeId $ScopeId -OptionId 3).value
		if ($ScopeIdList.Length -gt 1) { Write-Output "=========================================="; }
	}
}
 
<#
	.SYNOPSIS
		get name of WDS for a given env
	.DESCRIPTION
		get name of WDS for a given env
	.PARAMETER EnvName
		A description of the EnvName parameter.
	.EXAMPLE
				PS C:\> get-WDSComputernameForEnvironment -EnvName 'BL2'  => "BL2GR1WDS401"
	.NOTES
		Additional information about the function.
#>
function get-WDSComputernameForEnvironment
{
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[string]$EnvName
	)
	switch -wildcard ($EnvName)
	{
		"BN1*" { "BN1RGR5WDS401" }
		"SN5*" { "SN5AGR5WDS401" }
		"P20*" { "P20AGR5WDS401" }
		default
		{
			
			Write-Output "" # not a WDS
		}
	}
}

######################################################################################################
## Function to confirm the rolename is set to 2022
######################################################################################################

# next map to the proper new sku, this can be flushed out and is used for function 
# if "2019-##########" => "2022-Gen5-###-A.1"
# 
#   Sync-OldRolenameToNewOsRolename -RoleName "CCS-MI-DomCont-F.1" -OS_2012_2016 2012  => 2012-Gen4-ADS-A.1
#
function Sync-OldRolenameToNewOsRolename {   
    param(
    [string]$RoleName
    )

    $Server2022Prefix = "2022"

	if ($RoleName.Substring(0, 4) -ne "2022")
	{
        $2022RoleName = $Server2022Prefix + $RoleName.Substring(4)
        return $2022RoleName        
	}
	else
	{
	    # just return the original as we have no idea on the mapping
        return $RoleName
	}
}
function ReplaceThirdToLastDigit {
    param(
        [string]$str
    )

    $index = $str.Length - 3
    return $str.Substring(0, $index) + "8" + $str.Substring($index + 1)
}

######################################################################################################
##  Tools to convert prestage for blade to 2022
######################################################################################################
 
<# E.g.  Convert-2022PrestageFromAD MACHINE101
   will generate this output:
   =======================
  $params = @{ 
    "ComputerName" = "MACHINE801" 
    "NetbootGuid" = [guid]"38373238-3537-4d32-3235-333630384750" 
    "NetworkAddress" = "10.47.144.158;255.255.254.0;10.47.144.1;10.47.137.20,10.47.137.21,10.15.43.20,10.15.43.21"
    "RoleName" = "2022-Gen5-XXX-A.1" 
    "WdsServer" = "WDSSERVER" 
   }
  # To prestage, (1) first verify the above, then (2) run this workflow if correct:
  # New-GenericWorkflow -WorkflowName "PrestageServerWorkflow" -WorkflowParameters `$params
   =======================
  #>
<#
	.SYNOPSIS
		get Prestage data from AD and prepare it with Server 2022 appropriate values for the specific Cluster
	.DESCRIPTION
		get Prestage data from AD
		We also try to map old SKU/Rolename to new ones which is why
		we also prompt for the OSVersion
	.PARAMETER ComputerName
		A description of the ComputerName parameter.
	.EXAMPLE
				PS C:\> Export-PrestageFromAD -ComputerName 'Value1'
	.NOTES
		Additional information about the function.
#>
function Convert-2022PrestageFromAD
{
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[string]$ComputerName
	)
	[string]$ComputerName = $ComputerName.Trim()
	$ad = get-adcomputer $ComputerName -prop *
	$guid = (dechex $ad.netbootGUID)
	$NetworkAddress = $ad.Networkaddress
	$RoleName = (Sync-OldRolenameToNewOsRolename -RoleName "$($ad.description)")
	$WdsServer = $ad.netbootMachineFilePath
	$ConvertedComputerName = ReplaceThirdToLastDigit($ComputerName)

	return @"
	New-GenericWorkflow -WorkflowName "PrestageServerWorkflow" -WorkflowParameters @{ 
    "ComputerName" = "$ConvertedComputerName" 
    “NetbootGuid” = [System.Guid]::new(“$guid”) 
    "NetworkAddress" = "$NetworkAddress"
    "RoleName" = "$RoleName"
    "WdsServer" = "$WdsServer" 
  } -Wait

  Get-AdComputer "$ConvertedComputerName" -Properties * | Select-Object netbootmirrordatafile
 
"@
}
 
######################################################################################################
##  Tools to get prestage data out of AD
######################################################################################################
 
<# E.g.  Export-PrestageFromAD CH1GR1ADS301
   will generate this output:
   =======================
  $params = @{ 
    "ComputerName" = "CH1GR1ADS301" 
    "NetbootGuid" = [guid]"38373238-3537-4d32-3235-333630384750" 
    "NetworkAddress" = "10.47.144.158;
    "WdsServer" = "CH1GR1WDS001" 
   }
  # To prestage, (1) first verify the above, then (2) run this workflow if correct:
  # New-GenericWorkflow -WorkflowName "PrestageServerWorkflow" -WorkflowParameters `$params
   =======================
 
#>
 
<#
	.SYNOPSIS
		get Prestage data from AD
	.DESCRIPTION
		get Prestage data from AD
	.PARAMETER ComputerName
		A description of the ComputerName parameter.
	.EXAMPLE
				PS C:\> Export-PrestageFromAD -ComputerName 'Value1'
	.NOTES
		Additional information about the function.
#>
function Export-PrestageFromAD
{
	param
	(
		[Parameter(Mandatory = $true,
				   Position = 1)]
		[string]$ComputerName
	)
	[string]$ComputerName = $ComputerName.Trim()
	$ad = get-adcomputer $ComputerName -prop *
	$guid = (dechex $ad.netbootGUID)
	$NetworkAddress = $ad.Networkaddress
	$RoleName = ($ad.description)
	$WdsServer = $ad.netbootMachineFilePath
	return @"
  `$params = @{ 
    "ComputerName" = "$ComputerName" 
    “NetbootGuid” = [System.Guid]::new(“$guid”) 
    "NetworkAddress" = "$NetworkAddress"
    "RoleName" = "$RoleName"
    "WdsServer" = "$WdsServer" 
  }
  # To prestage, (1) first verify the above, then (2) run this workflow if correct:
  # New-GenericWorkflow -WorkflowName "PrestageServerWorkflow" -WorkflowParameters `$params -Wait
 
"@
}

 
# low level function to help fetch AD guid info and put in proper format
Function dechex($b)
{
	#Split values in $b onto seperate lines
	$b = $b -split (",")
	# Convert Values in $b into HEX
	$b = ForEach ($value in $b)
	{
		"{0:x}" -f [Int]$value
	}
	#Reorder first half of numbers because Microsoft mixes first half of decimal GUID
	$b = $b[3], $b[2], $b[1], $b[0], $b[5], $b[4], $b[7], $b[6], $b[8], $b[9], $b[10], $b[11], $b[12], $b[13], $b[14], $b[15]
	#Rejoin split numbers
	#$b=$b -join (",")
	#Pad with zeros when only single value present
	$GUID = foreach ($value in $b)
	{
		if ($value.length -le 1)
		{
			'0' + $value
		}
		else
		{
			$value
		}
	}
	#format into GUID format
	#$GUID = #"{" `
	$GUID = "" `
	+ $GUID[0] `
	+ $GUID[1] `
	+ $GUID[2] `
	+ $GUID[3] `
	+ "-" `
	+ $GUID[4] `
	+ $GUID[5] `
	+ "-" `
	+ $GUID[6] `
	+ $GUID[7] `
	+ "-" `
	+ $GUID[8] `
	+ $GUID[9] `
	+ "-" `
	+ $GUID[10] `
	+ $GUID[11] `
	+ $GUID[12] `
	+ $GUID[13] `
	+ $GUID[14] `
	+ $GUID[15] `
	+ ""
	#+ "}"
	Return [string]$GUID
}
  
######################################################################################################
##  Tools to get prestage data off the live actual running server
######################################################################################################
 
 
<# The following is a tool to run ON THE SERVER to get prestage data directly from it.
You can run it by getting local admin on it or via invoke-command from an ADM (shown
below)
 
Q: how to run?
 
(a)  remotely from an ADM
     =======================
PS C:\Users\multijit_vyx0\tmp> $fl
BY1GR1DS010G10
BY1GR1DS013G10
BY1GR1DS037G10
BY1GR1DS038G10
 
PS C:\Users\multijit_vyx0\tmp> $fl | %{ invoke-command $_ $lambda_get_prestage_data_from_server; }
 
(b)  directly on a machine
     =======================
If you are on the box directly, instead just source in this script to get the 
lambda/script block and do this on the machine itself:
 
&  $lambda_get_prestage_data_from_server;
 
#>
 
function Read-PrestageDataOffBaremetal ([string]$ComputerName)
{
	switch ($ComputerName)
	{
		"" { & $lambda_get_prestage_data_from_server;  }
		"localhost" { & $lambda_get_prestage_data_from_server; }
		"$(hostname)" { & $lambda_get_prestage_data_from_server; }
		default
		{
			Invoke-Command $ComputerName $lambda_get_prestage_data_from_server;
		}
	}
}
 
$lambda_get_prestage_data_from_server = {
<# build something like this:
   "NetworkAddress" = "25.145.124.30;255.255.254.0;25.145.124.1;25.145.53.155,25.145.53.156"
      "NetworkAddress" = "25.145.124.30;255.255.254.0;25.145.124.1;25.145.53.155,25.145.53.156"
#>
	function Get-PrestageNetworkAddress ($NetworkData)
	{
		if ($NetworkData.IsDHCPEnabled -or ($NetworkData.IsDHCPEnabled -eq "true"))
		{
			"DHCP"
		}
		else
		{
			("{0};{1};{2};{3}" -f @(
					$NetworkData.IPAddress,
					$NetworkData.SubnetMask,
					(Get-DefaultGateway  $NetworkData.DefaultGateway),
					($NetworkData.DNSServers -join ",")
				))
		}
	}
<# $DefaultGateway_array might be 25.144.83.4 2a01:111:5:7::4 #>
	function Get-DefaultGateway  ($DefaultGateway_array)
	{
		$ipv4 = $DefaultGateway_array[0]
		# BUGBUG : need to make sure last digit is a 1
		return "$($ipv4)||??||Remember<-lastdigit_should_prob_be_.1||"
	}

	$guid = [guid](Get-WmiObject Win32_ComputerSystemProduct).UUID

	$Networks = Get-WmiObject win32_networkadapterconfiguration
	$Networks = $Networks | Where-Object { $_.DefaultIPGateway -ne $null }
	$ResultArray = @()
	foreach ($Network in $Networks)
	{
		$IPAddress = $Network.IpAddress[0]
		$SubnetMask = $Network.IPSubnet[0]
		$DefaultGateway = $Network.DefaultIPGateway
		$DNSServers = $Network.DNSServerSearchOrder
		$WINS1 = $Network.WINSPrimaryServer
		$WINS2 = $Network.WINSSecondaryServer
		$WINS = @($WINS1, $WINS2)
		$IsDHCPEnabled = $false
		If ($network.DHCPEnabled)
		{
			$IsDHCPEnabled = $true
		}
		$ResultObject = New-Object PSObject -Property @{
			'IPAddress'  = $($IPAddress)
			'SubnetMask' = $($SubnetMask)
			'DefaultGateway' = $($DefaultGateway)
			'DNSServers' = $($DNSServers)
			'WINS1'	     = $($WINS1)
			'WINS2'	     = $($WINS2)
			'WINS'	     = $($WINS)
			'IsDHCPEnabled' = $($IsDHCPEnabled)
		}
		#    'PrestageNetworkAddress' = "$($IsDHCPEnabled)"
		Add-member -InputObject $ResultObject -Name "PrestageNetworkAddress" -Value "$(Get-PrestageNetworkAddress -NetworkData $ResultObject)" -MemberType NoteProperty
		# save for later, also below add it to the output
		$ResultArray += $ResultObject
		$ResultObject
	}
<# might return
DefaultGateway       : 25.144.83.4 2a01:111:5:7::4
SubnetMask           : 255.255.255.0
WINS                 :  
DNSServers           : 25.144.84.123 25.144.84.124 25.144.84.125 10.15.56.143 25.145.56.12
IsDHCPEnabled        : False  << = a string type
WINS2                : 
IPAddress            : 25.144.83.12
WINS1                : 
PrestageNetworkAddress : 
PrestageNetworkAddress : PrestageNetworkAddress
#>

	$guid = [guid](Get-WmiObject Win32_ComputerSystemProduct).UUID
	Write-Output "netbootGUID is $($guid)"
}
 
 
set-alias dns-get-prestage-networking-info-doctor Get-PrestageNetworkingInfo
set-alias tjp-dns-get-prestage-networking-info-doctor Get-PrestageNetworkingInfo
set-alias dms-Repair-TopologyDrives  Repair-TopologyDrives