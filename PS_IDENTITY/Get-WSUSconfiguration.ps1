
function Global:colorMyconsole {

cls
[console]::BackgroundColor = "black"
$a = (Get-Host).PrivateData
$a.ErrorBackgroundColor = "Black"
$a.ErrorForegroundColor = "White"
$a.WarningBackgroundColor = "Black"
$a.WarningForegroundColor = "DarkYellow"

Set-PSReadlineOption -TokenKind Comment -f Gray
Set-PSReadlineOption -TokenKind Parameter DarkGreen
Set-PSReadlineOption -TokenKind Variable DarkCyan
Set-PSReadlineOption -TokenKind Member DarkGray

} 

colorMyconsole
<#.\load-wsusconfigmodule.ps1 configure-2016WSUS-server -SqlSysClr:$True -RepViewer:$True -wsusDirPath 'e:\wsus' -tempDir 'C:\$_.temp.jjs.workflow\' -configWSUS:$True -declineUpdates:$false -definitionApprov:$True -minorApprov:$True -rundefRule:$True -wid_WSUS WID#>
function Global:configure-2016WSUS-server{

[CmdletBinding()]param(  

[Parameter(Position = 0, Mandatory = $false, ValueFromPipeline = $false, HelpMessage = 'Would you like to install Report View Runtime?')]  
[switch]$RepViewer=$True,

[Parameter(Position = 1, Mandatory = $True, ValueFromPipeline = $true, HelpMessage = 'Would you like to install SqlSysClr?')]
[switch]$SqlSysClr=$True,

[Parameter(Position = 2, Mandatory = $false, ValueFromPipeline = $false, HelpMessage = 'Provide WSUS Directory path!')]
[string]$wsusDirPath='E:\WSUS',

[Parameter(Position = 3, Mandatory = $true, ValueFromPipeline = $true, HelpMessage = 'Provide temporary workflow path!')]
[string]$tempDir='C:\$_.temp.jjs.workflow\',

[Parameter(Position = 4, Mandatory = $True, ValueFromPipeline = $true, HelpMessage = 'Would you like to confiture WSUS?')]
[switch]$configWSUS=$True,

[Parameter(Position = 5, Mandatory = $True, ValueFromPipeline = $true, HelpMessage = 'Would you like to decline WSUS update?"')]
[switch]$declineUpdates=$False,

[Parameter(Position = 6, Mandatory = $True, ValueFromPipeline = $true, HelpMessage = 'Would you like to setup with defualt approval scheme?"')]
[switch]$definitionApprov =$True,

[Parameter(Position = 7, Mandatory = $True, ValueFromPipeline = $true, HelpMessage = 'Would you like to setup with defualt approval scheme?"')]
[switch]$minorApprov =$True,

[Parameter(Position = 8, Mandatory = $True, ValueFromPipeline = $true, HelpMessage = 'Would you like to setup rule with defualt rule scheme?"')]
[switch]$rundefRule=$True,

[Parameter(Position = 9, Mandatory = $True, ValueFromPipeline = $true, HelpMessage = 'Would you like to configure WSUS server with WID Windows Internal Database?"')]
[string]$wid_WSUS='WID',

[Parameter(Position = 10, Mandatory = $false)]
$o = (
"-",
"Please",
"download",
"downloaded",
"and",
"install",
"Installing",
"Installed",
"Initializing",
"Downloading",
"Setting",
"Microsoft Report Viewer 2012 Runtime",
"could",
"be",
"it",
"is",
"manually",
"Successfully",
"to",
"for",
"did",
"not",
"use",
"correctly",
"WSUS",
"Report",
"Report",
"Working",
"SqlSysClrType",
".",
"Sync",
"get",
"available",
"Products",
"Classifications",
"will",
"take",
"sometime",
"to",
"complete",
"open",
"Validation",
"the",
"console",
"cancel",
"configuration",
"Configuring",
"wizard",
"Go",
"options",
"check",
"that",
"are",
"set",
"Enabling",
"Automatic",
"Synchronisation",
"done",
"Approving",
"Declining",
"unwanted",
"updates",
"progress",
"default",
"rule",
"This",
"stage",
"may",
"timeout",
"but",
"applied",
"workflow",
"continue",
"Cleaning",
"temp",
"directory",
"log",
"files",
"can",
"found",
"here",
"WID",
"Windows Internal Database",
"Click",
"OK",
"Starting",
"Running",
"approval",
"failed",
"ReportViwer",
"already",
"Post",
"started",
"installation",
"Synced",
"Added",
"Steps",
"Workflow",
"Stopped",
"Resuming",
"Saved",
"IIS",
"Administration",
"module",
"AppPool",
"Exist",
"queueLength",
"from",
"loadBalancerCapabilities",
"TcpLevel",
"Fail",
"Protection",
"Interval",
"less",
"than",
"greater",
"FailProtectionMaxCrashes",
"now",
"Private",
"Memory",
"NT AUTHORITY",
"NETWORK SERVICE",
"Adding",
"Security",
"Group",
"Created",
"Creating",
"definition",
"Saving",
"Syncing",
"Security",
"minor",
"components",
"processed",
"Downloadexpress",
"enabled",
"Schtask",
"Invoke WSUS Cleanup",
"IE Enhanced Security Configuration 'ESC'",
"enabled",
"PatchApprovals",
"in"
)

)

$splashScreen = @"
------------------------------------------------------------------------------------------------------------
Author: v-jaju@microsoft.com
Date: July 03, 2018
Build & Configure 2016 WSUS Server 
Version: 1.03
------------------------------------------------------------------------------------------------------------
"@

function global:CountDown([int]$waitMinutes,[string]$Statlabel) 
{

$array = (
"/",
"\",
"|",
"-"
)

$startTime = get-date
$endTime   = $startTime.addMinutes($waitMinutes)
$timeSpan = new-timespan $startTime $endTime

while ($timeSpan -gt 0)
{
$l = get-random $array
$timeSpan = new-timespan $(get-date) $endTime
write-host "`r".padright(0," ") -nonewline
write-host $([string]::Format("$l $($Statlabel): {0:d2}:{1:d2}:{2:d2}", $timeSpan.hours, $timeSpan.minutes, $timeSpan.seconds)) -NoNewline -foregroundcolor Gray
sleep 1

}
}

$ispath = test-path -path 'C:\$_.temp.jjs.workflow\'
if($ispath -eq $False){mkdir $tempDir 2>&1 | out-file _$.0}

$invokeWSUSCleanupXMLfile = (
'<?xml version="1.0" encoding="UTF-16"?>',
'<Task version="1.2" xmlns="http://schemas.microsoft.com/windows/2004/02/mit/task">',
'  <RegistrationInfo>',
'    <Date>2017-11-17T13:47:20.5953176</Date>',
'    <Author>GME\wayoung</Author>',
'    <URI>\Invoke WSUS Cleanup</URI>',
'  </RegistrationInfo>',
'  <Triggers>',
'    <CalendarTrigger>',
'      <StartBoundary>2017-11-17T05:00:00</StartBoundary>',
'      <Enabled>true</Enabled>',
'      <ScheduleByDay>',
'        <DaysInterval>1</DaysInterval>',
'      </ScheduleByDay>',
'    </CalendarTrigger>',
'  </Triggers>',
'  <Principals>',
'    <Principal id="Author">',
'      <UserId>S-1-5-18</UserId>',
'      <RunLevel>LeastPrivilege</RunLevel>',
'    </Principal>',
'  </Principals>',
'  <Settings>',
'    <MultipleInstancesPolicy>IgnoreNew</MultipleInstancesPolicy>',
'    <DisallowStartIfOnBatteries>true</DisallowStartIfOnBatteries>',
'    <StopIfGoingOnBatteries>true</StopIfGoingOnBatteries>',
'    <AllowHardTerminate>true</AllowHardTerminate>',
'    <StartWhenAvailable>true</StartWhenAvailable>',
'    <RunOnlyIfNetworkAvailable>false</RunOnlyIfNetworkAvailable>',
'    <IdleSettings>',
'      <StopOnIdleEnd>true</StopOnIdleEnd>',
'      <RestartOnIdle>false</RestartOnIdle>',
'    </IdleSettings>',
'    <AllowStartOnDemand>true</AllowStartOnDemand>',
'    <Enabled>true</Enabled>',
'    <Hidden>false</Hidden>',
'    <RunOnlyIfIdle>false</RunOnlyIfIdle>',
'    <WakeToRun>false</WakeToRun>',
'    <ExecutionTimeLimit>PT12H</ExecutionTimeLimit>',
'    <Priority>7</Priority>',
'  </Settings>',
'  <Actions Context="Author">',
'    <Exec>',
'       <!-- Script Contents:',
'          write-host (get-date): Starting cleanup wizard',
'       Invoke-WsusServerCleanup -CleanupObsoleteComputers -CleanupObsoleteUpdates -CleanupUnneededContentFiles -DeclineExpiredUpdates',
'       write-host (get-date): Compressing Updates',
'       Invoke-WsusServerCleanup -CompressUpdates',
'     -->',
'      <Command>Powershell.exe</Command>',
'      <Arguments>-enc dwByAGkAdABlAC0AaABvAHMAdAAgACgAZwBlAHQALQBkAGEAdABlACkAOgAgAFMAdABhAHIAdABpAG4AZwAgAGMAbABlAGEAbgB1AHAAIAB3AGkAegBhAHIAZAAKAEkAbgB2AG8AawBlAC0AVwBzAHUAcwBTAGUAcgB2AGUAcgBDAGwAZQBhAG4AdQBwACAALQBDAGwAZQBhAG4AdQBwAE8AYgBzAG8AbABlAHQAZQBDAG8AbQBwAHUA
dABlAHIAcwAgAC0AQwBsAGUAYQBuAHUAcABPAGIAcwBvAGwAZQB0AGUAVQBwAGQAYQB0AGUAcwAgAC0AQwBsAGUAYQBuAHUAcABVAG4AbgBlAGUAZABlAGQAQwBvAG4AdABlAG4AdABGAGkAbABlAHMAIAAtAEQAZQBjAGwAaQBuAGUARQB4AHAAaQByAGUAZABVAHAAZABhAHQAZQBzACAALQBEAGUAYwBsAGkAbgBlAFMAdQBwAGUAcgBzAGUAZABlAGQAVQBwAGQ
AYQB0AGUAcwAKAHcAcgBpAHQAZQAtAGgAbwBzAHQAIAAoAGcAZQB0AC0AZABhAHQAZQApADoAIABDAG8AbQBwAHIAZQBzAHMAaQBuAGcAIABVAHAAZABhAHQAZQBzAAoASQBuAHYAbwBrAGUALQBXAHMAdQBzAFMAZQByAHYAZQByAEMAbABlAGEAbgB1AHAAIAAtAEMAbwBtAHAAcgBlAHMAcwBVAHAAZABhAHQAZQBzAA==</Arguments>',
'    </Exec>',
'  </Actions>',
'</Task>'
)

$WSUSSQLIndexesPSfile = (
'##One time run on WSUS Servers after the SQL database has been created',
'##',
'##This vastly reduces the daily maintenance time ',
'##',
'$wsus = Get-WSUSServer',
'$db = $wsus.GetDatabaseConfiguration().CreateConnection()',
'$db.QueryTimeOut = 1500',
'$db.Connect()',
'$db.ExecuteCommandNoResult("CREATE NONCLUSTERED INDEX [IX_tbRevisionSupersedesUpdate] ON [SUSDB].[dbo].[tbRevisionSupersedesUpdate]([SupersededUpdateID])", [System.Data.CommandType]::Text)',
'$db.CloseCommand()',
'$db.Close()',
'$db.Connect()',
'$db.ExecuteCommandNoResult("CREATE NONCLUSTERED INDEX [IX_tbLocalizedPropertyForRevision] ON [SUSDB].[dbo].[tbLocalizedPropertyForRevision]([LocalizedPropertyID])", [System.Data.CommandType]::Text)',
'$db.CloseCommand()',
'$db.Close()',
'',
'',
'# SIG # Begin signature block',
'# MIInMAYJKoZIhvcNAQcCoIInITCCJx0CAQExDzANBglghkgBZQMEAgEFADB5Bgor',
'# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG',
'# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCDOwXRFqbowKwsg',
'# nxvkqENbTYxQwdxCbw7BX5nub1mkwKCCEOwwggf+MIIG5qADAgECAhM2AAAARiAh',
'# 8uEqu9czAAEAAABGMA0GCSqGSIb3DQEBCwUAMEExEzARBgoJkiaJk/IsZAEZFgNH',
'# QkwxEzARBgoJkiaJk/IsZAEZFgNBTUUxFTATBgNVBAMTDEFNRSBDUyBDQSAwMTAe',
'# Fw0xNzA4MTUwODI3MDBaFw0xODA4MTUwODI3MDBaMC8xLTArBgNVBAMTJE1pY3Jv',
'# c29mdCBBenVyZSBEZXBlbmRlbmN5IENvZGUgU2lnbjCCASIwDQYJKoZIhvcNAQEB',
'# BQADggEPADCCAQoCggEBAOAPentM4dHO5fzyo80izhehlg9UXtYoBD1j6lIEXIVg',
'# dzdaNJcvmVHPmMX/nNPBffF5tnUtRR+6FJ2kcgneLU0ThiefPVDL6Sj53YfFShU8',
'# RcirIsD1T6swk5M/TQOKeTkICbKokiu/BsXtu/5QpXwv7wu03HzcnnyJwSGbfIyU',
'# A9fsmkqmkzgt2RNw5/eyqjg31WKG50uC40fCZePCXy15WPkRa+DphFZTXTfQL34N',
'# SAryFK0Z96XaoFV3WkW88auFBY/I1DSR5Su6O5uRIkw1CuEIOVEp8IfeRKpOr8UK',
'# l5Es3M5udwUQePYb0HEyJZqVvjBD2uyJcbabx/CznOkCAwEAAaOCBP8wggT7MA4G',
'# A1UdDwEB/wQEAwIHgDAfBgNVHSUEGDAWBgorBgEEAYI3WwMBBggrBgEFBQcDAzAd',
'# BgNVHQ4EFgQUP+TiZz3XTY3MtkCKaFQYH4vkQ5QwUQYDVR0RBEowSKRGMEQxDDAK',
'# BgNVBAsTA0FPQzE0MDIGA1UEBRMrMjM2MTY5KzE0YjExMDNlLTMzZDQtNGIyYi04',
'# MTJhLWNlMDg0OTA2ODMzNjAfBgNVHSMEGDAWgBQbZqIZ/JvrpdqEjxiY6RCkw3uS',
'# vTCCAaQGA1UdHwSCAZswggGXMIIBk6CCAY+gggGLhi5odHRwOi8vY3JsMS5hbWUu',
'# Z2JsL2NybC9BTUUlMjBDUyUyMENBJTIwMDEuY3JshjxodHRwOi8vY3JsLm1pY3Jv',
'# c29mdC5jb20vcGtpaW5mcmEvQ1JML0FNRSUyMENTJTIwQ0ElMjAwMS5jcmyGLmh0',
'# dHA6Ly9jcmwyLmFtZS5nYmwvY3JsL0FNRSUyMENTJTIwQ0ElMjAwMS5jcmyGLmh0',
'# dHA6Ly9jcmwzLmFtZS5nYmwvY3JsL0FNRSUyMENTJTIwQ0ElMjAwMS5jcmyGgbps',
'# ZGFwOi8vL0NOPUFNRSUyMENTJTIwQ0ElMjAwMSxDTj1CWTJQS0lDU0NBMDEsQ049',
'# Q0RQLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNv',
'# bmZpZ3VyYXRpb24sREM9QU1FLERDPUdCTD9jZXJ0aWZpY2F0ZVJldm9jYXRpb25M',
'# aXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwggIiBggr',
'# BgEFBQcBAQSCAhQwggIQMFIGCCsGAQUFBzAChkZodHRwOi8vY3JsMS5hbWUuZ2Js',
'# L2FpYS9CWTJQS0lDU0NBMDEuQU1FLkdCTF9BTUUlMjBDUyUyMENBJTIwMDEoMSku',
'# Y3J0MGIGCCsGAQUFBzAChlZodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpaW5m',
'# cmEvQ2VydHMvQlkyUEtJQ1NDQTAxLkFNRS5HQkxfQU1FJTIwQ1MlMjBDQSUyMDAx',
'# KDEpLmNydDBSBggrBgEFBQcwAoZGaHR0cDovL2NybDIuYW1lLmdibC9haWEvQlky',
'# UEtJQ1NDQTAxLkFNRS5HQkxfQU1FJTIwQ1MlMjBDQSUyMDAxKDEpLmNydDBSBggr',
'# BgEFBQcwAoZGaHR0cDovL2NybDMuYW1lLmdibC9haWEvQlkyUEtJQ1NDQTAxLkFN',
'# RS5HQkxfQU1FJTIwQ1MlMjBDQSUyMDAxKDEpLmNydDCBrQYIKwYBBQUHMAKGgaBs',
'# ZGFwOi8vL0NOPUFNRSUyMENTJTIwQ0ElMjAwMSxDTj1BSUEsQ049UHVibGljJTIw',
'# S2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1B',
'# TUUsREM9R0JMP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZp',
'# Y2F0aW9uQXV0aG9yaXR5MDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIaQ4w2E',
'# 1bR4hPGLPoWb3RbOnRKBYOKCLYeQrgMCAWQCAQkwKQYJKwYBBAGCNxUKBBwwGjAM',
'# BgorBgEEAYI3WwMBMAoGCCsGAQUFBwMDMA0GCSqGSIb3DQEBCwUAA4IBAQA/m1ri',
'# h+qBqPtJj4K0xWoWJ+zVwDKZhXM/d2CcTYkEsxB2LKo3h7wsn5DIo8iNl0OHf+Rv',
'# RV2L2s0TWTTcno2BCaYgnfKpnf31w+T1XRxsfdzYtIVDCTgTxpkts2s8g7mG4tEL',
'# WP25IYu2aq934Y/SDTs1PQHgCBx1LAtDACYcdLCCiyVnLznsPeX2qKyTV0KT7hxX',
'# ZaP07RHcDaHY1Lb15So2R7tbg1Zz9iYLRhx69Dkd8uiGDN9udV6RaSVbxVIILV1O',
'# +LigwXelGUaVOX2utWM2KEVp9gmqYTBRXvA+MmiW5VZvdBQm9AYeR12gfWWnAccv',
'# 41EBIFXghf7TzPWcMIII5jCCBs6gAwIBAgITHwAAABS0xR/G8oC+cQAAAAAAFDAN',
'# BgkqhkiG9w0BAQsFADA8MRMwEQYKCZImiZPyLGQBGRYDR0JMMRMwEQYKCZImiZPy',
'# LGQBGRYDQU1FMRAwDgYDVQQDEwdhbWVyb290MB4XDTE2MDkxNTIxMzMwM1oXDTIx',
'# MDkxNTIxNDMwM1owQTETMBEGCgmSJomT8ixkARkWA0dCTDETMBEGCgmSJomT8ixk',
'# ARkWA0FNRTEVMBMGA1UEAxMMQU1FIENTIENBIDAxMIIBIjANBgkqhkiG9w0BAQEF',
'# AAOCAQ8AMIIBCgKCAQEA1VeBAtb5+tD3G4C53TfNJNxmYfzhiXKtKQzSGxuav660',
'# bTS1VEeDDjSnFhsmnlb6GkPCeYmCJwWgZGs+3oWJ8yad3//VoP99bXG8azzTJmT2',
'# PFM1yKxUXUJgi7I9y3C4ll/ATfBwbGGRXD+2PdkdlVpxKWzeNEPVwbCtxWjUhHr6',
'# Ecy9R6O23j+2/RSZSgfzYctDzDWhNf0PvGPflm31PSk4+ozca337/Ozu0+naDKg5',
'# i/zFHhfSJZkq5dPPG6C8wDrdiwHh6G5IGrMd2QXnmvEfjtpPqE+G8MeWbszaWxlx',
'# EjQJQC6PBwn+8Qt4Vqlc0am3Z3fBw8kzRunOs8Mn/wIDAQABo4IE2jCCBNYwEAYJ',
'# KwYBBAGCNxUBBAMCAQEwIwYJKwYBBAGCNxUCBBYEFJH8M85CnvaT5uJ9VNcIGLu4',
'# 13FlMB0GA1UdDgQWBBQbZqIZ/JvrpdqEjxiY6RCkw3uSvTCCAQQGA1UdJQSB/DCB',
'# +QYHKwYBBQIDBQYIKwYBBQUHAwEGCCsGAQUFBwMCBgorBgEEAYI3FAIBBgkrBgEE',
'# AYI3FQYGCisGAQQBgjcKAwwGCSsGAQQBgjcVBgYIKwYBBQUHAwkGCCsGAQUFCAIC',
'# BgorBgEEAYI3QAEBBgsrBgEEAYI3CgMEAQYKKwYBBAGCNwoDBAYJKwYBBAGCNxUF',
'# BgorBgEEAYI3FAICBgorBgEEAYI3FAIDBggrBgEFBQcDAwYKKwYBBAGCN1sBAQYK',
'# KwYBBAGCN1sCAQYKKwYBBAGCN1sDAQYKKwYBBAGCN1sFAQYKKwYBBAGCN1sEAQYK',
'# KwYBBAGCN1sEAjAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMC',
'# AYYwEgYDVR0TAQH/BAgwBgEB/wIBADAfBgNVHSMEGDAWgBQpXlFeZK40ueusnA2n',
'# jHUB0QkLKDCCAWgGA1UdHwSCAV8wggFbMIIBV6CCAVOgggFPhiNodHRwOi8vY3Js',
'# MS5hbWUuZ2JsL2NybC9hbWVyb290LmNybIYxaHR0cDovL2NybC5taWNyb3NvZnQu',
'# Y29tL3BraWluZnJhL2NybC9hbWVyb290LmNybIYjaHR0cDovL2NybDIuYW1lLmdi',
'# bC9jcmwvYW1lcm9vdC5jcmyGI2h0dHA6Ly9jcmwzLmFtZS5nYmwvY3JsL2FtZXJv',
'# b3QuY3JshoGqbGRhcDovLy9DTj1hbWVyb290LENOPUFNRVJPT1QsQ049Q0RQLENO',
'# PVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3Vy',
'# YXRpb24sREM9QU1FLERDPUdCTD9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jh',
'# c2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwggGrBggrBgEFBQcB',
'# AQSCAZ0wggGZMDcGCCsGAQUFBzAChitodHRwOi8vY3JsMS5hbWUuZ2JsL2FpYS9B',
'# TUVST09UX2FtZXJvb3QuY3J0MEcGCCsGAQUFBzAChjtodHRwOi8vY3JsLm1pY3Jv',
'# c29mdC5jb20vcGtpaW5mcmEvY2VydHMvQU1FUk9PVF9hbWVyb290LmNydDA3Bggr',
'# BgEFBQcwAoYraHR0cDovL2NybDIuYW1lLmdibC9haWEvQU1FUk9PVF9hbWVyb290',
'# LmNydDA3BggrBgEFBQcwAoYraHR0cDovL2NybDMuYW1lLmdibC9haWEvQU1FUk9P',
'# VF9hbWVyb290LmNydDCBogYIKwYBBQUHMAKGgZVsZGFwOi8vL0NOPWFtZXJvb3Qs',
'# Q049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENO',
'# PUNvbmZpZ3VyYXRpb24sREM9QU1FLERDPUdCTD9jQUNlcnRpZmljYXRlP2Jhc2U/',
'# b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlvbkF1dGhvcml0eTANBgkqhkiG9w0BAQsF',
'# AAOCAgEAKLdKhpqPH6QBaM3CAOqQi8oA4WQeZLW3QOXNmWm7UA018DQEa1yTqEQb',
'# uD5OlR1Wu/F289DmXNTdsZM4GTKEaZehIiVaMoLvEJtu5h6CTyfWqPetNyOJqR1s',
'# Gqod0Xwn5/G/zcTYSxn5K3N8KdlcDrZAIyfq3yaEJYHGnA9eJ/f1RrfbJgeo/RAh',
'# ICctOONwfpsBXcgiTuTmlD/k0DqogvzJgPq9GOkIyX/dxk7IkPzX/n484s0zHR4I',
'# KU58U3G1oPSQmZ5OHAvgHaEASkdN5E20HyJv5zN7du+QY08fI+VIci6pagLfXHYa',
'# TX3ZJ/MUM9XU+oU5y4qMLzTj1JIG0LVfuHK8yoB7h2inyTe7bn6h2G8NxZ02aKZ0',
'# xa+n/JnoXKNsaVPG1SoTuItMsXV5pQtIShsBqnXqFjY3bJMlMhIofMcjiuOwRCW+',
'# prZ+PoYvE2P+ML7gs3L65GZ9BdKF3fSW3TvmpOujPQ23rzSle9WGxFJ02fNbaF9C',
'# 7bG44uDzMoZU4P+uvQaB7KE4OMqAvYYfFy1tv1dpVIN/qhx0H/9oNiOJpuZZ39Zi',
'# bLt9DXbsq5qwyHmdJXaisxwB53wJshUjc1i76xqFPUNGb8EZQ3aFKl2w9B47vfBi',
'# +nU3sN0tpnLPtew4LHWq4LBD5uiNZVBOYosZ6BKhSlk1+Y/0y1IxghWaMIIVlgIB',
'# ATBYMEExEzARBgoJkiaJk/IsZAEZFgNHQkwxEzARBgoJkiaJk/IsZAEZFgNBTUUx',
'# FTATBgNVBAMTDEFNRSBDUyBDQSAwMQITNgAAAEYgIfLhKrvXMwABAAAARjANBglg',
'# hkgBZQMEAgEFAKCBxjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE',
'# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgxtaLUNh8pOFE',
'# jijZCt1TOWYtW8CDTRP4d7UoxOehepIwWgYKKwYBBAGCNwIBDDFMMEqgLIAqAE0A',
'# aQBjAHIAbwBzAG8AZgB0ACAAQwBvAHIAcABvAHIAYQB0AGkAbwBuoRqAGGh0dHA6',
'# Ly93d3cubWljcm9zb2Z0LmNvbTANBgkqhkiG9w0BAQEFAASCAQASCailw93cON6y',
'# 0TDJZQNSh7jYyab3w2QIcM8A+xMlQuHrTypQhbGGr4Q0VYzizukHfkx3vQ2Any44',
'# KzTWH9Ey4Zeuwg5HT7OydG9BR7oqhUWW1y7snNlR3QbPNgiL9XAEhsMp/RIh8ctM',
'# zFFFQPx20VbGZT5I7U0WWwna7ytRVI4M6+FKvweIf9/MB19dlR3WBh9YA40XHbSI',
'# vJNQKmYxZRoJyDkChPoaftZOFHQ9AVLEB/eBJnWXVqCCpHWQ5R0wWhYYRUpTO2dy',
'# 3Kz6dNJR9bmGiYW1AQiWLbmIERKrjURyL/Kx+jZp8gRDIyASU9C9e0+CuHm8y3Mf',
'# y8AYnUUjoYITSjCCE0YGCisGAQQBgjcDAwExghM2MIITMgYJKoZIhvcNAQcCoIIT',
'# IzCCEx8CAQMxDzANBglghkgBZQMEAgEFADCCAT0GCyqGSIb3DQEJEAEEoIIBLASC',
'# ASgwggEkAgEBBgorBgEEAYRZCgMBMDEwDQYJYIZIAWUDBAIBBQAEIE05aqShu/XM',
'# qHxbF4tn+bsbgGqMExcE1KluIKCcVs79AgZbBEPY6FYYEzIwMTgwNjE1MDIzMjQx',
'# LjIwMVowBwIBAYACAfSggbmkgbYwgbMxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX',
'# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg',
'# Q29ycG9yYXRpb24xDTALBgNVBAsTBE1PUFIxJzAlBgNVBAsTHm5DaXBoZXIgRFNF',
'# IEVTTjpCOEVDLTMwQTQtNzE0NDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3Rh',
'# bXAgU2VydmljZaCCDs0wggZxMIIEWaADAgECAgphCYEqAAAAAAACMA0GCSqGSIb3',
'# DQEBCwUAMIGIMQswCQYDVQQGEwJVUzETMBEGA1UECBMKV2FzaGluZ3RvbjEQMA4G',
'# A1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9zb2Z0IENvcnBvcmF0aW9uMTIw',
'# MAYDVQQDEylNaWNyb3NvZnQgUm9vdCBDZXJ0aWZpY2F0ZSBBdXRob3JpdHkgMjAx',
'# MDAeFw0xMDA3MDEyMTM2NTVaFw0yNTA3MDEyMTQ2NTVaMHwxCzAJBgNVBAYTAlVT',
'# MRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQK',
'# ExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1l',
'# LVN0YW1wIFBDQSAyMDEwMIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA',
'# qR0NvHcRijog7PwTl/X6f2mUa3RUENWlCgCChfvtfGhLLF/Fw+Vhwna3PmYrW/AV',
'# UycEMR9BGxqVHc4JE458YTBZsTBED/FgiIRUQwzXTbg4CLNC3ZOs1nMwVyaCo0UN',
'# 0Or1R4HNvyRgMlhgRvJYR4YyhB50YWeRX4FUsc+TTJLBxKZd0WETbijGGvmGgLvf',
'# YfxGwScdJGcSchohiq9LZIlQYrFd/XcfPfBXday9ikJNQFHRD5wGPmd/9WbAA5ZE',
'# fu/QS/1u5ZrKsajyeioKMfDaTgaRtogINeh4HLDpmc085y9Euqf03GS9pAHBIAmT',
'# eM38vMDJRF1eFpwBBU8iTQIDAQABo4IB5jCCAeIwEAYJKwYBBAGCNxUBBAMCAQAw',
'# HQYDVR0OBBYEFNVjOlyKMZDzQ3t8RhvFM2hahW1VMBkGCSsGAQQBgjcUAgQMHgoA',
'# UwB1AGIAQwBBMAsGA1UdDwQEAwIBhjAPBgNVHRMBAf8EBTADAQH/MB8GA1UdIwQY',
'# MBaAFNX2VsuP6KJcYmjRPZSQW9fOmhjEMFYGA1UdHwRPME0wS6BJoEeGRWh0dHA6',
'# Ly9jcmwubWljcm9zb2Z0LmNvbS9wa2kvY3JsL3Byb2R1Y3RzL01pY1Jvb0NlckF1',
'# dF8yMDEwLTA2LTIzLmNybDBaBggrBgEFBQcBAQROMEwwSgYIKwYBBQUHMAKGPmh0',
'# dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9wa2kvY2VydHMvTWljUm9vQ2VyQXV0XzIw',
'# MTAtMDYtMjMuY3J0MIGgBgNVHSABAf8EgZUwgZIwgY8GCSsGAQQBgjcuAzCBgTA9',
'# BggrBgEFBQcCARYxaHR0cDovL3d3dy5taWNyb3NvZnQuY29tL1BLSS9kb2NzL0NQ',
'# Uy9kZWZhdWx0Lmh0bTBABggrBgEFBQcCAjA0HjIgHQBMAGUAZwBhAGwAXwBQAG8A',
'# bABpAGMAeQBfAFMAdABhAHQAZQBtAGUAbgB0AC4gHTANBgkqhkiG9w0BAQsFAAOC',
'# AgEAB+aIUQ3ixuCYP4FxAz2do6Ehb7Prpsz1Mb7PBeKp/vpXbRkws8LFZslq3/Xn',
'# 8Hi9x6ieJeP5vO1rVFcIK1GCRBL7uVOMzPRgEop2zEBAQZvcXBf/XPleFzWYJFZL',
'# dO9CEMivv3/Gf/I3fVo/HPKZeUqRUgCvOA8X9S95gWXZqbVr5MfO9sp6AG9LMEQk',
'# IjzP7QOllo9ZKby2/QThcJ8ySif9Va8v/rbljjO7Yl+a21dA6fHOmWaQjP9qYn/d',
'# xUoLkSbiOewZSnFjnXshbcOco6I8+n99lmqQeKZt0uGc+R38ONiU9MalCpaGpL2e',
'# Gq4EQoO4tYCbIjggtSXlZOz39L9+Y1klD3ouOVd2onGqBooPiRa6YacRy5rYDkea',
'# gMXQzafQ732D8OE7cQnfXXSYIghh2rBQHm+98eEA3+cxB6STOvdlR3jo+KhIq/fe',
'# cn5ha293qYHLpwmsObvsxsvYgrRyzR30uIUBHoD7G4kqVDmyW9rIDVWZeodzOwjm',
'# mC3qjeAzLhIp9cAvVCch98isTtoouLGp25ayp0Kiyc8ZQU3ghvkqmqMRZjDTu3Qy',
'# S99je/WZii8bxyGvWbWu3EQ8l1Bx16HSxVXjad5XwdHeMMD9zOZN+w2/XU/pnR4Z',
'# OC+8z1gFLu8NoFA12u8JJxzVs341Hgi62jbb01+P3nSISRIwggTaMIIDwqADAgEC',
'# AhMzAAAAn2fytagjBlt7AAAAAACfMA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYT',
'# AlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYD',
'# VQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBU',
'# aW1lLVN0YW1wIFBDQSAyMDEwMB4XDTE2MDkwNzE3NTY0N1oXDTE4MDkwNzE3NTY0',
'# N1owgbMxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQH',
'# EwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDTALBgNV',
'# BAsTBE1PUFIxJzAlBgNVBAsTHm5DaXBoZXIgRFNFIEVTTjpCOEVDLTMwQTQtNzE0',
'# NDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZTCCASIwDQYJ',
'# KoZIhvcNAQEBBQADggEPADCCAQoCggEBALkI8SOc3cQCLwKFoaMnl2T5A5wSVD9T',
'# glq4Put9bhjFcsEn1XApDPCWS9aPhMcWOWKe+7ENI4Si4zD30nVQC9PZ0NDu+pK9',
'# XV83OfjGchFkKzOBRddOhpsQkxFgMF3RfLTNXAEqffnNaReXwtVUkiGEJvW6KmAB',
'# ixzP0aeUVmJ6MHnJnmo+TKZdoVl7cg6TY6LCoze/F6rhOXmi/P3X/K3jHtmAaxL9',
'# Ou53jjDgO5Rjxt6ZEamdEsGF2SWZ6wH6Dmg9G6iZPxgw+mjODwReL6jwh7H2Xhsv',
'# zoFMrSERMzIIf2eJGAM9C0GR0BZHyRti17QqL5TaCuWPjMxTKXX4DlkCAwEAAaOC',
'# ARswggEXMB0GA1UdDgQWBBT9ixsiw30jR3amHt/gZtRS6bb5oDAfBgNVHSMEGDAW',
'# gBTVYzpcijGQ80N7fEYbxTNoWoVtVTBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8v',
'# Y3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNUaW1TdGFQQ0Ff',
'# MjAxMC0wNy0wMS5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRw',
'# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1RpbVN0YVBDQV8yMDEw',
'# LTA3LTAxLmNydDAMBgNVHRMBAf8EAjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0G',
'# CSqGSIb3DQEBCwUAA4IBAQBlEMFsa88VHq8PSDbr3y0LvAAA5pFmGlCWZbkxD2WM',
'# qfF0y8fnlvgb874z8sz8QZzByCmY1jHyHTc98Zekz7L2Y5SANUIa8jyU36c64Ck5',
'# fY6Pe9hUA1RG/1zP+eq080chUPCF2zezhfwuz9Ob0obO64BwW0GZgYYz1hjsq+DB',
'# kSCBRV59ryFpzgKRwhWF8quXtHDpimiJx+ds2VZSwEVk/QRY7pLuUvedN8P5DNuL',
'# aaRw3oJcs2Wxh2jWS5T8Y3JevUo3K3VTtHPi2IBWISkEG7TOnNEUcUXDMGSOeZ27',
'# kuPFzKkDVbtzvwEVepkGrsZ1W+1xuDYPQ1b3BMG8C79HoYIDdjCCAl4CAQEwgeOh',
'# gbmkgbYwgbMxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD',
'# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDTAL',
'# BgNVBAsTBE1PUFIxJzAlBgNVBAsTHm5DaXBoZXIgRFNFIEVTTjpCOEVDLTMwQTQt',
'# NzE0NDElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaIlCgEB',
'# MAkGBSsOAwIaBQADFQBs0ycI8vnZqMv5Gd6SS0qt2xmjwaCBwjCBv6SBvDCBuTEL',
'# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v',
'# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjENMAsGA1UECxMETU9Q',
'# UjEnMCUGA1UECxMebkNpcGhlciBOVFMgRVNOOjU3RjYtQzFFMC01NTRDMSswKQYD',
'# VQQDEyJNaWNyb3NvZnQgVGltZSBTb3VyY2UgTWFzdGVyIENsb2NrMA0GCSqGSIb3',
'# DQEBBQUAAgUA3s2FhDAiGA8yMDE4MDYxNTAwMjMzMloYDzIwMTgwNjE2MDAyMzMy',
'# WjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDezYWEAgEAMAcCAQACAgcGMAcCAQAC',
'# AhqsMAoCBQDeztcEAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwGg',
'# CjAIAgEAAgMW42ChCjAIAgEAAgMHoSAwDQYJKoZIhvcNAQEFBQADggEBAB8gTQ54',
'# DZSDqvBCuobbl2PhiHJ/QBmDTMc7pwrx8qry8lfXwpqHByN6gzeclLvcHtrjthRj',
'# cCbcbJie6XLumlknieLkwIb4OaHPc1EurJgWCsECkRdiHqdYozHxZofSRObBsnX+',
'# wBufY3LYkH/Sgg8Bun6rRrCs+8Hf8Hi92wlqaNyACB6iGucYbivx7qz1+jNOVx+q',
'# gxL8COpw21vuc3OmxcXoCnki/NKL6cRz8NVZJckFoDYgojiGzMfMVpeQcf+kIw7e',
'# x8jn/PwYB0WhEsL4325OayzY18Qc1Oz1z7n7RR+tA6zTQxGFaG6CbY+5hnY1Mee8',
'# 3rfAlUEO8gbd8+0xggL1MIIC8QIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UE',
'# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z',
'# b2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQ',
'# Q0EgMjAxMAITMwAAAJ9n8rWoIwZbewAAAAAAnzANBglghkgBZQMEAgEFAKCCATIw',
'# GgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCDOX/gi',
'# RNFGKcFl8S4IDVgWfk+akMcdklBWAPc8xTvzkDCB4gYLKoZIhvcNAQkQAgwxgdIw',
'# gc8wgcwwgbEEFGzTJwjy+dmoy/kZ3pJLSq3bGaPBMIGYMIGApH4wfDELMAkGA1UE',
'# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc',
'# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0',
'# IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAACfZ/K1qCMGW3sAAAAAAJ8wFgQUbpW0',
'# KlhX5NJkes4FgnCI7fgZsqEwDQYJKoZIhvcNAQELBQAEggEAnM/3pXUJC83A+bKE',
'# /KFl+KpZQlsWpMA5ipkJNswYqdGPgEe2ROfnIf/uAa8zfmmqJEzRuM5Scn6lwXAX',
'# csuDY28iYzqHyyBXF4q9K9iAPQ5tIJV1FdXU15nkly+K3Ko5m3l1er3Fq2fL23wU',
'# /E9H2a5RD8l9aBCzbz3U0VpMyvSr2/mUxTVpJdMS7ioCLPY7yTeqTcW4O/TQo6VQ',
'# v4LqG2gLn5T1W5mtDuD5ZpA+OAmgT+VIj8IkYrsvcraEijOtfX3W9L6P3YLdDvaP',
'# NlMHqmJ1p2GbcIpWjnwKBF8OG4CveCeqRfjRfnvnPQ2Ts8Ditz/7VtGmP7yFN3IB',
'# 88+8Qg==',
'# SIG # End signature block'
)

$approveWSUSpatchPSfile = (
'##ApproveWSUSPatches.ps1',
'##',
'param (',
'  [switch]$forceLocal,         ##Use the local WSUS server instead of locating the active instance',
'  [switch]$declineSuperseded,  ##Decline all Superseded updates',
'  [switch]$whatif              ##Show the actions it would take but dont actually execute them.',
')',
'',
'##Use the local WSUS if we make it do so, otherwise look up the current WSUS server from the registry',
'if ($forceLocal) {',
'  $wuServer = $env:Computername',
'  $wsus = Get-WsusServer',
'} else {',
'$wuRegKey =  (Get-ItemProperty HKLM:\Software\Policies\Microsoft\Windows\WindowsUpdate).WuServer',
'$wuServerProps = $wuRegKey.Split(":")',
'$useSSL = $wuServerProps[0] -eq "https"',
'$wuServer = $wuServerProps[1].Replace("/","")',
'$wuPort = $wuServerProps[2]',
'if ($wuPort -eq $null) {$wuPort = if ($useSSL) {"443"} else {"80"}}',
'$wsus = Get-WsusServer -Name $wuServer -Port $wuPort -UseSSL:$useSSL',
'}',
'',
'if ($wsus -eq $null) {',
'  Write-Host -ForegroundColor Red "Could not connect to WSUS Server: $($env:Computername). Cannot continue"',
'  exit',
'}',
'',
'#Currently only supporting the AllComputers Group',
'$targetGroup = $wsus.GetComputerTargetGroups() | where {$_.Name -eq "All Computers"}',
'if ($whatif) {Write-Host -ForegroundColor Yellow "This process was executed using the -WhatIf parameter. No changes will be made."}',
'',
'#Process Patch Approval List',
'$patchesToApprove = gc .\PatchApprovalList.txt',
'Foreach ($pta in $patchesToApprove) ',
'{',
'  if ($pta -match "##") {continue} ##skip comments in the Patch Approval List',
'  ',
'  $udl=@()',
'  $udl = $wsus.SearchUpdates($pta) | where {$_.KnowledgeBaseArticles -eq $($pta.Replace("KB","")) -and $_.IsLatestRevision}',
'  ',
'  if ($udl.Count -eq 0) {Write-Host -ForegroundColor Yellow "Update Not Found: $pta. You may need to download this from the catalog at https://catalog.update.microsoft.com"}',
'  ',
'  foreach ($update in $udl) {',
'    #Already approved, or explicitly Declined. Move on to the next one',
'       ',
'       if ($update.IsDeclined)  {Write-Host -ForegroundColor DarkYellow "$pta ~ $($update.LegacyName) was previously declined and will not be approved. To approve this update, you must approve it manually"; Continue}',
'',
'       #Warn if this update is superseded',
'       if ($update.IsSuperseded) {',
'      $supmsg = "$pta ~ $($update.LegacyName) is marked as Superseded. "',
'      if ($declineSuperseded) {',
'         Write-Host -ForegroundColor Yellow "$supmsg The declineSuperseded flag was specified so this update will be declined"',
'         if (!$whatif) {$update.Decline()}',
'      } else {',
'         if ($update.IsApproved) {',
'           Write-Host -ForegroundColor Yellow "$supmsg This update was previously approved. Check the superseding update then decline this."',
'         } else {',
'           Write-Host -ForegroundColor Yellow "$supmsg This update will not be approved. Check the superseding update then decline this. "',
'         }',
'      }',
'      continue;',
'    }',
'     ',
'    #Already approved',
'       if ($update.IsApproved) {Write-Host -ForegroundColor Green "$pta ~ $($update.LegacyName) is already approved"; Continue}',
'',
'       #Accept License Agreements',
'       if ($update.RequiresLicenseAgreementAcceptance) {',
'         Write-Host -ForegroundColor Yellow "$pta ~ $($update.LegacyName) requires license agreement acceptance. Approving License Agreement"',
'         if (!$whatif) {$update.AcceptLicenseAgreement()}',
'       }',
'       ',
'       #Approve Update',
'         Write-Host -ForegroundColor Yellow "$pta ~ $($update.LegacyName) requires requires approval. Approving Update."',
'         if (!$whatif) {$update.Approve("Install",$targetGroup)}',
'  }',
'}',
'',
'#Process all patches that were already approved in WSUS (via automatic or previous manual approvals)',
'',
'##Find approved updates ',
'Write-Host ''',
'Write-Host "Checking for approved updates that were not in the approved list..."',
'Write-Host ""',
'',
'$UpdateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope',
'$appStates = [Microsoft.UpdateServices.Administration.ApprovedStates]',
'$UpdateScope.ApprovedStates = $appStates::HasStaleUpdateApprovals -bor $appStates::LatestRevisionApproved',
'$existingApprovals = $wsus.GetUpdates($UpdateScope)',
'',
'foreach ($u in $existingApprovals) {',
'  if ($patchesToApprove -cmatch $u.KnowledgebaseArticles) {Continue} #This was processed with the input list, so ignore it here',
'',
'  $msgbase = "KB$($u.KnowledgebaseArticles) is approved "',
'  ',
'  #Not Superseded, add it to patches or decline it',
'  if (!($u.IsSuperseded)) {',
'     $msgbase += " but not in the patch approval file. Check if needed then add or decline it."',
'     $neededBy = (Get-WsusUpdate -UpdateId $u.Id.UpdateId).ComputersNeedingThisUpdate',
'     Write-Host -ForegroundColor Yellow "$msgbase It is currently needed by $neededBy Computers."',
'     continue;',
'  } ',
'  ',
'  #Superseded Update',
'   $msgbase += "but Superseded."',
'   if ($declineSuperseded) {',
'     Write-Host -ForegroundColor Yellow "$msgbase The declineSuperseded flag was specified so it will be declined now."',
'     if (!$whatif) {$u.Decline()}',
'   } else {',
'     Write-Host -ForegroundColor Yellow "$msgbase The declineSuperseded flag was not specified and will not be modified."',
'   }',
'',
'}',
'# SIG # Begin signature block',
'# MIInMAYJKoZIhvcNAQcCoIInITCCJx0CAQExDzANBglghkgBZQMEAgEFADB5Bgor',
'# BgEEAYI3AgEEoGswaTA0BgorBgEEAYI3AgEeMCYCAwEAAAQQH8w7YFlLCE63JNLG',
'# KX7zUQIBAAIBAAIBAAIBAAIBADAxMA0GCWCGSAFlAwQCAQUABCB/EZy11Eh1iA/x',
'# KGyKrVjUHcQtmqkwKgyb+2kr2wNejKCCEOwwggf+MIIG5qADAgECAhM2AAAARiAh',
'# 8uEqu9czAAEAAABGMA0GCSqGSIb3DQEBCwUAMEExEzARBgoJkiaJk/IsZAEZFgNH',
'# QkwxEzARBgoJkiaJk/IsZAEZFgNBTUUxFTATBgNVBAMTDEFNRSBDUyBDQSAwMTAe',
'# Fw0xNzA4MTUwODI3MDBaFw0xODA4MTUwODI3MDBaMC8xLTArBgNVBAMTJE1pY3Jv',
'# c29mdCBBenVyZSBEZXBlbmRlbmN5IENvZGUgU2lnbjCCASIwDQYJKoZIhvcNAQEB',
'# BQADggEPADCCAQoCggEBAOAPentM4dHO5fzyo80izhehlg9UXtYoBD1j6lIEXIVg',
'# dzdaNJcvmVHPmMX/nNPBffF5tnUtRR+6FJ2kcgneLU0ThiefPVDL6Sj53YfFShU8',
'# RcirIsD1T6swk5M/TQOKeTkICbKokiu/BsXtu/5QpXwv7wu03HzcnnyJwSGbfIyU',
'# A9fsmkqmkzgt2RNw5/eyqjg31WKG50uC40fCZePCXy15WPkRa+DphFZTXTfQL34N',
'# SAryFK0Z96XaoFV3WkW88auFBY/I1DSR5Su6O5uRIkw1CuEIOVEp8IfeRKpOr8UK',
'# l5Es3M5udwUQePYb0HEyJZqVvjBD2uyJcbabx/CznOkCAwEAAaOCBP8wggT7MA4G',
'# A1UdDwEB/wQEAwIHgDAfBgNVHSUEGDAWBgorBgEEAYI3WwMBBggrBgEFBQcDAzAd',
'# BgNVHQ4EFgQUP+TiZz3XTY3MtkCKaFQYH4vkQ5QwUQYDVR0RBEowSKRGMEQxDDAK',
'# BgNVBAsTA0FPQzE0MDIGA1UEBRMrMjM2MTY5KzE0YjExMDNlLTMzZDQtNGIyYi04',
'# MTJhLWNlMDg0OTA2ODMzNjAfBgNVHSMEGDAWgBQbZqIZ/JvrpdqEjxiY6RCkw3uS',
'# vTCCAaQGA1UdHwSCAZswggGXMIIBk6CCAY+gggGLhi5odHRwOi8vY3JsMS5hbWUu',
'# Z2JsL2NybC9BTUUlMjBDUyUyMENBJTIwMDEuY3JshjxodHRwOi8vY3JsLm1pY3Jv',
'# c29mdC5jb20vcGtpaW5mcmEvQ1JML0FNRSUyMENTJTIwQ0ElMjAwMS5jcmyGLmh0',
'# dHA6Ly9jcmwyLmFtZS5nYmwvY3JsL0FNRSUyMENTJTIwQ0ElMjAwMS5jcmyGLmh0',
'# dHA6Ly9jcmwzLmFtZS5nYmwvY3JsL0FNRSUyMENTJTIwQ0ElMjAwMS5jcmyGgbps',
'# ZGFwOi8vL0NOPUFNRSUyMENTJTIwQ0ElMjAwMSxDTj1CWTJQS0lDU0NBMDEsQ049',
'# Q0RQLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNv',
'# bmZpZ3VyYXRpb24sREM9QU1FLERDPUdCTD9jZXJ0aWZpY2F0ZVJldm9jYXRpb25M',
'# aXN0P2Jhc2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwggIiBggr',
'# BgEFBQcBAQSCAhQwggIQMFIGCCsGAQUFBzAChkZodHRwOi8vY3JsMS5hbWUuZ2Js',
'# L2FpYS9CWTJQS0lDU0NBMDEuQU1FLkdCTF9BTUUlMjBDUyUyMENBJTIwMDEoMSku',
'# Y3J0MGIGCCsGAQUFBzAChlZodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtpaW5m',
'# cmEvQ2VydHMvQlkyUEtJQ1NDQTAxLkFNRS5HQkxfQU1FJTIwQ1MlMjBDQSUyMDAx',
'# KDEpLmNydDBSBggrBgEFBQcwAoZGaHR0cDovL2NybDIuYW1lLmdibC9haWEvQlky',
'# UEtJQ1NDQTAxLkFNRS5HQkxfQU1FJTIwQ1MlMjBDQSUyMDAxKDEpLmNydDBSBggr',
'# BgEFBQcwAoZGaHR0cDovL2NybDMuYW1lLmdibC9haWEvQlkyUEtJQ1NDQTAxLkFN',
'# RS5HQkxfQU1FJTIwQ1MlMjBDQSUyMDAxKDEpLmNydDCBrQYIKwYBBQUHMAKGgaBs',
'# ZGFwOi8vL0NOPUFNRSUyMENTJTIwQ0ElMjAwMSxDTj1BSUEsQ049UHVibGljJTIw',
'# S2V5JTIwU2VydmljZXMsQ049U2VydmljZXMsQ049Q29uZmlndXJhdGlvbixEQz1B',
'# TUUsREM9R0JMP2NBQ2VydGlmaWNhdGU/YmFzZT9vYmplY3RDbGFzcz1jZXJ0aWZp',
'# Y2F0aW9uQXV0aG9yaXR5MDwGCSsGAQQBgjcVBwQvMC0GJSsGAQQBgjcVCIaQ4w2E',
'# 1bR4hPGLPoWb3RbOnRKBYOKCLYeQrgMCAWQCAQkwKQYJKwYBBAGCNxUKBBwwGjAM',
'# BgorBgEEAYI3WwMBMAoGCCsGAQUFBwMDMA0GCSqGSIb3DQEBCwUAA4IBAQA/m1ri',
'# h+qBqPtJj4K0xWoWJ+zVwDKZhXM/d2CcTYkEsxB2LKo3h7wsn5DIo8iNl0OHf+Rv',
'# RV2L2s0TWTTcno2BCaYgnfKpnf31w+T1XRxsfdzYtIVDCTgTxpkts2s8g7mG4tEL',
'# WP25IYu2aq934Y/SDTs1PQHgCBx1LAtDACYcdLCCiyVnLznsPeX2qKyTV0KT7hxX',
'# ZaP07RHcDaHY1Lb15So2R7tbg1Zz9iYLRhx69Dkd8uiGDN9udV6RaSVbxVIILV1O',
'# +LigwXelGUaVOX2utWM2KEVp9gmqYTBRXvA+MmiW5VZvdBQm9AYeR12gfWWnAccv',
'# 41EBIFXghf7TzPWcMIII5jCCBs6gAwIBAgITHwAAABS0xR/G8oC+cQAAAAAAFDAN',
'# BgkqhkiG9w0BAQsFADA8MRMwEQYKCZImiZPyLGQBGRYDR0JMMRMwEQYKCZImiZPy',
'# LGQBGRYDQU1FMRAwDgYDVQQDEwdhbWVyb290MB4XDTE2MDkxNTIxMzMwM1oXDTIx',
'# MDkxNTIxNDMwM1owQTETMBEGCgmSJomT8ixkARkWA0dCTDETMBEGCgmSJomT8ixk',
'# ARkWA0FNRTEVMBMGA1UEAxMMQU1FIENTIENBIDAxMIIBIjANBgkqhkiG9w0BAQEF',
'# AAOCAQ8AMIIBCgKCAQEA1VeBAtb5+tD3G4C53TfNJNxmYfzhiXKtKQzSGxuav660',
'# bTS1VEeDDjSnFhsmnlb6GkPCeYmCJwWgZGs+3oWJ8yad3//VoP99bXG8azzTJmT2',
'# PFM1yKxUXUJgi7I9y3C4ll/ATfBwbGGRXD+2PdkdlVpxKWzeNEPVwbCtxWjUhHr6',
'# Ecy9R6O23j+2/RSZSgfzYctDzDWhNf0PvGPflm31PSk4+ozca337/Ozu0+naDKg5',
'# i/zFHhfSJZkq5dPPG6C8wDrdiwHh6G5IGrMd2QXnmvEfjtpPqE+G8MeWbszaWxlx',
'# EjQJQC6PBwn+8Qt4Vqlc0am3Z3fBw8kzRunOs8Mn/wIDAQABo4IE2jCCBNYwEAYJ',
'# KwYBBAGCNxUBBAMCAQEwIwYJKwYBBAGCNxUCBBYEFJH8M85CnvaT5uJ9VNcIGLu4',
'# 13FlMB0GA1UdDgQWBBQbZqIZ/JvrpdqEjxiY6RCkw3uSvTCCAQQGA1UdJQSB/DCB',
'# +QYHKwYBBQIDBQYIKwYBBQUHAwEGCCsGAQUFBwMCBgorBgEEAYI3FAIBBgkrBgEE',
'# AYI3FQYGCisGAQQBgjcKAwwGCSsGAQQBgjcVBgYIKwYBBQUHAwkGCCsGAQUFCAIC',
'# BgorBgEEAYI3QAEBBgsrBgEEAYI3CgMEAQYKKwYBBAGCNwoDBAYJKwYBBAGCNxUF',
'# BgorBgEEAYI3FAICBgorBgEEAYI3FAIDBggrBgEFBQcDAwYKKwYBBAGCN1sBAQYK',
'# KwYBBAGCN1sCAQYKKwYBBAGCN1sDAQYKKwYBBAGCN1sFAQYKKwYBBAGCN1sEAQYK',
'# KwYBBAGCN1sEAjAZBgkrBgEEAYI3FAIEDB4KAFMAdQBiAEMAQTALBgNVHQ8EBAMC',
'# AYYwEgYDVR0TAQH/BAgwBgEB/wIBADAfBgNVHSMEGDAWgBQpXlFeZK40ueusnA2n',
'# jHUB0QkLKDCCAWgGA1UdHwSCAV8wggFbMIIBV6CCAVOgggFPhiNodHRwOi8vY3Js',
'# MS5hbWUuZ2JsL2NybC9hbWVyb290LmNybIYxaHR0cDovL2NybC5taWNyb3NvZnQu',
'# Y29tL3BraWluZnJhL2NybC9hbWVyb290LmNybIYjaHR0cDovL2NybDIuYW1lLmdi',
'# bC9jcmwvYW1lcm9vdC5jcmyGI2h0dHA6Ly9jcmwzLmFtZS5nYmwvY3JsL2FtZXJv',
'# b3QuY3JshoGqbGRhcDovLy9DTj1hbWVyb290LENOPUFNRVJPT1QsQ049Q0RQLENO',
'# PVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENOPUNvbmZpZ3Vy',
'# YXRpb24sREM9QU1FLERDPUdCTD9jZXJ0aWZpY2F0ZVJldm9jYXRpb25MaXN0P2Jh',
'# c2U/b2JqZWN0Q2xhc3M9Y1JMRGlzdHJpYnV0aW9uUG9pbnQwggGrBggrBgEFBQcB',
'# AQSCAZ0wggGZMDcGCCsGAQUFBzAChitodHRwOi8vY3JsMS5hbWUuZ2JsL2FpYS9B',
'# TUVST09UX2FtZXJvb3QuY3J0MEcGCCsGAQUFBzAChjtodHRwOi8vY3JsLm1pY3Jv',
'# c29mdC5jb20vcGtpaW5mcmEvY2VydHMvQU1FUk9PVF9hbWVyb290LmNydDA3Bggr',
'# BgEFBQcwAoYraHR0cDovL2NybDIuYW1lLmdibC9haWEvQU1FUk9PVF9hbWVyb290',
'# LmNydDA3BggrBgEFBQcwAoYraHR0cDovL2NybDMuYW1lLmdibC9haWEvQU1FUk9P',
'# VF9hbWVyb290LmNydDCBogYIKwYBBQUHMAKGgZVsZGFwOi8vL0NOPWFtZXJvb3Qs',
'# Q049QUlBLENOPVB1YmxpYyUyMEtleSUyMFNlcnZpY2VzLENOPVNlcnZpY2VzLENO',
'# PUNvbmZpZ3VyYXRpb24sREM9QU1FLERDPUdCTD9jQUNlcnRpZmljYXRlP2Jhc2U/',
'# b2JqZWN0Q2xhc3M9Y2VydGlmaWNhdGlvbkF1dGhvcml0eTANBgkqhkiG9w0BAQsF',
'# AAOCAgEAKLdKhpqPH6QBaM3CAOqQi8oA4WQeZLW3QOXNmWm7UA018DQEa1yTqEQb',
'# uD5OlR1Wu/F289DmXNTdsZM4GTKEaZehIiVaMoLvEJtu5h6CTyfWqPetNyOJqR1s',
'# Gqod0Xwn5/G/zcTYSxn5K3N8KdlcDrZAIyfq3yaEJYHGnA9eJ/f1RrfbJgeo/RAh',
'# ICctOONwfpsBXcgiTuTmlD/k0DqogvzJgPq9GOkIyX/dxk7IkPzX/n484s0zHR4I',
'# KU58U3G1oPSQmZ5OHAvgHaEASkdN5E20HyJv5zN7du+QY08fI+VIci6pagLfXHYa',
'# TX3ZJ/MUM9XU+oU5y4qMLzTj1JIG0LVfuHK8yoB7h2inyTe7bn6h2G8NxZ02aKZ0',
'# xa+n/JnoXKNsaVPG1SoTuItMsXV5pQtIShsBqnXqFjY3bJMlMhIofMcjiuOwRCW+',
'# prZ+PoYvE2P+ML7gs3L65GZ9BdKF3fSW3TvmpOujPQ23rzSle9WGxFJ02fNbaF9C',
'# 7bG44uDzMoZU4P+uvQaB7KE4OMqAvYYfFy1tv1dpVIN/qhx0H/9oNiOJpuZZ39Zi',
'# bLt9DXbsq5qwyHmdJXaisxwB53wJshUjc1i76xqFPUNGb8EZQ3aFKl2w9B47vfBi',
'# +nU3sN0tpnLPtew4LHWq4LBD5uiNZVBOYosZ6BKhSlk1+Y/0y1IxghWaMIIVlgIB',
'# ATBYMEExEzARBgoJkiaJk/IsZAEZFgNHQkwxEzARBgoJkiaJk/IsZAEZFgNBTUUx',
'# FTATBgNVBAMTDEFNRSBDUyBDQSAwMQITNgAAAEYgIfLhKrvXMwABAAAARjANBglg',
'# hkgBZQMEAgEFAKCBxjAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAcBgorBgEE',
'# AYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAvBgkqhkiG9w0BCQQxIgQgqZX+2nmJ62sh',
'# TJLIEMpLU1ZdG5cADYbPq/A/PKcieyUwWgYKKwYBBAGCNwIBDDFMMEqgLIAqAE0A',
'# aQBjAHIAbwBzAG8AZgB0ACAAQwBvAHIAcABvAHIAYQB0AGkAbwBuoRqAGGh0dHA6',
'# Ly93d3cubWljcm9zb2Z0LmNvbTANBgkqhkiG9w0BAQEFAASCAQBTv8m/0XUt2rDh',
'# uxdfNv5gZNhrcb0yryO6QDhYEdFowtHaIHOXIVWeILQU5kn+tMkaMG2bG1dodJn/',
'# Ak9eoWQ7x/AMVHOmsXAAPxBukf+Mgz4UJYIodah6FeT22jD7mntmADejLhLnPHqY',
'# QK1JAH8i7bisd016fx/lGsKaZ88U/cTFpSn2cgECAWOPAkTUb8NTKcdI7w/XScZ0',
'# iLKug2mXQ8tdOS+8v6d8zkEiISr2Y2RmhkOpYA2pArpX/GqsS30wvydm9cmS2edm',
'# upsCLUleDu/w3HZ1izAk2mqWrGnaEJHdjjK8LCmRNf8/d+AAcrTeRiEuBZ81+4b5',
'# EMfaDSHaoYITSjCCE0YGCisGAQQBgjcDAwExghM2MIITMgYJKoZIhvcNAQcCoIIT',
'# IzCCEx8CAQMxDzANBglghkgBZQMEAgEFADCCAT0GCyqGSIb3DQEJEAEEoIIBLASC',
'# ASgwggEkAgEBBgorBgEEAYRZCgMBMDEwDQYJYIZIAWUDBAIBBQAEIJJTiQbp66pE',
'# uYWsbnz/qcklrRUtag2+Dhsqh7RO2TC2AgZbGzQwwawYEzIwMTgwNjE1MDIzMjM0',
'# LjM3N1owBwIBAYACAfSggbmkgbYwgbMxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpX',
'# YXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQg',
'# Q29ycG9yYXRpb24xDTALBgNVBAsTBE1PUFIxJzAlBgNVBAsTHm5DaXBoZXIgRFNF',
'# IEVTTjpCMUI3LUY2N0YtRkVDMjElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3Rh',
'# bXAgU2VydmljZaCCDs0wggTaMIIDwqADAgECAhMzAAAAsXETed919jXIAAAAAACx',
'# MA0GCSqGSIb3DQEBCwUAMHwxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5n',
'# dG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9y',
'# YXRpb24xJjAkBgNVBAMTHU1pY3Jvc29mdCBUaW1lLVN0YW1wIFBDQSAyMDEwMB4X',
'# DTE2MDkwNzE3NTY1N1oXDTE4MDkwNzE3NTY1N1owgbMxCzAJBgNVBAYTAlVTMRMw',
'# EQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYDVQQHEwdSZWRtb25kMR4wHAYDVQQKExVN',
'# aWNyb3NvZnQgQ29ycG9yYXRpb24xDTALBgNVBAsTBE1PUFIxJzAlBgNVBAsTHm5D',
'# aXBoZXIgRFNFIEVTTjpCMUI3LUY2N0YtRkVDMjElMCMGA1UEAxMcTWljcm9zb2Z0',
'# IFRpbWUtU3RhbXAgU2VydmljZTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoC',
'# ggEBAKqkJJRtWNZbvKG9D+3XrprkZ+Cb0YthhK5iveL4G51j5ndI//WqwO+d/Rw9',
'# XaRtboWG5pwMXPqrLrzDNH6RL7bUyuJWUlO7LOayX1pmxZ/yfJEhiPCvYgWgeoUJ',
'# CbiF+LIvaaTa/Ud6GSNx2yf8kZClD5OIaM6WOgpHoUXNP2X7urUIsqiO5gpV2GU1',
'# 48Pqy7Id/4HQb2A3d/MxQZZWn/t7opikIFE1xo2yn6mWZN7RFN4m1lT1MQJpsZRt',
'# 7Fk5V5lN9XwsP+k1cxoNudZavkOOjo23h/bwdkznKhLKODWotydQnTAGFHZXpVVb',
'# YEHSMf3PuR768NGOlu7hgQFp1ucCAwEAAaOCARswggEXMB0GA1UdDgQWBBROVz33',
'# iy4US1ey/CJe08+3J0QQOzAfBgNVHSMEGDAWgBTVYzpcijGQ80N7fEYbxTNoWoVt',
'# VTBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8vY3JsLm1pY3Jvc29mdC5jb20vcGtp',
'# L2NybC9wcm9kdWN0cy9NaWNUaW1TdGFQQ0FfMjAxMC0wNy0wMS5jcmwwWgYIKwYB',
'# BQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRwOi8vd3d3Lm1pY3Jvc29mdC5jb20v',
'# cGtpL2NlcnRzL01pY1RpbVN0YVBDQV8yMDEwLTA3LTAxLmNydDAMBgNVHRMBAf8E',
'# AjAAMBMGA1UdJQQMMAoGCCsGAQUFBwMIMA0GCSqGSIb3DQEBCwUAA4IBAQBz7o37',
'# tFvDwU6Y32Gj6wCiASynJY0+PmJ1m24Br5l1PDryFAwZJL/IDRhh0TuQ0skmggES',
'# M4J9siIXgKoehsDNsiq32+HlQmD3tQk5QrHkuUzr/k5//eZl4/jcU6r7jZq4YAla',
'# 9AkO298aCnMA3EG4O05nqw4GyL9pO3BKm2G1PwdzLUl/GY439GZ4HSqF9CWJABA2',
'# 2XITq0YlLQySLXoDymT3+go3h2I65isL0zlQs795VtLsodcm/zg3kR/lahDUhwm6',
'# BYhIqvSqSjDqXpNVb0IZiNim05UbyvOvYI9TcLlBx/HN1l7uANF9fggZlPLdIL3f',
'# 3xZUL8NOL3iloffOMIIGcTCCBFmgAwIBAgIKYQmBKgAAAAAAAjANBgkqhkiG9w0B',
'# AQsFADCBiDELMAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNV',
'# BAcTB1JlZG1vbmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEyMDAG',
'# A1UEAxMpTWljcm9zb2Z0IFJvb3QgQ2VydGlmaWNhdGUgQXV0aG9yaXR5IDIwMTAw',
'# HhcNMTAwNzAxMjEzNjU1WhcNMjUwNzAxMjE0NjU1WjB8MQswCQYDVQQGEwJVUzET',
'# MBEGA1UECBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMV',
'# TWljcm9zb2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1T',
'# dGFtcCBQQ0EgMjAxMDCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAKkd',
'# Dbx3EYo6IOz8E5f1+n9plGt0VBDVpQoAgoX77XxoSyxfxcPlYcJ2tz5mK1vwFVMn',
'# BDEfQRsalR3OCROOfGEwWbEwRA/xYIiEVEMM1024OAizQt2TrNZzMFcmgqNFDdDq',
'# 9UeBzb8kYDJYYEbyWEeGMoQedGFnkV+BVLHPk0ySwcSmXdFhE24oxhr5hoC732H8',
'# RsEnHSRnEnIaIYqvS2SJUGKxXf13Hz3wV3WsvYpCTUBR0Q+cBj5nf/VmwAOWRH7v',
'# 0Ev9buWayrGo8noqCjHw2k4GkbaICDXoeByw6ZnNPOcvRLqn9NxkvaQBwSAJk3jN',
'# /LzAyURdXhacAQVPIk0CAwEAAaOCAeYwggHiMBAGCSsGAQQBgjcVAQQDAgEAMB0G',
'# A1UdDgQWBBTVYzpcijGQ80N7fEYbxTNoWoVtVTAZBgkrBgEEAYI3FAIEDB4KAFMA',
'# dQBiAEMAQTALBgNVHQ8EBAMCAYYwDwYDVR0TAQH/BAUwAwEB/zAfBgNVHSMEGDAW',
'# gBTV9lbLj+iiXGJo0T2UkFvXzpoYxDBWBgNVHR8ETzBNMEugSaBHhkVodHRwOi8v',
'# Y3JsLm1pY3Jvc29mdC5jb20vcGtpL2NybC9wcm9kdWN0cy9NaWNSb29DZXJBdXRf',
'# MjAxMC0wNi0yMy5jcmwwWgYIKwYBBQUHAQEETjBMMEoGCCsGAQUFBzAChj5odHRw',
'# Oi8vd3d3Lm1pY3Jvc29mdC5jb20vcGtpL2NlcnRzL01pY1Jvb0NlckF1dF8yMDEw',
'# LTA2LTIzLmNydDCBoAYDVR0gAQH/BIGVMIGSMIGPBgkrBgEEAYI3LgMwgYEwPQYI',
'# KwYBBQUHAgEWMWh0dHA6Ly93d3cubWljcm9zb2Z0LmNvbS9QS0kvZG9jcy9DUFMv',
'# ZGVmYXVsdC5odG0wQAYIKwYBBQUHAgIwNB4yIB0ATABlAGcAYQBsAF8AUABvAGwA',
'# aQBjAHkAXwBTAHQAYQB0AGUAbQBlAG4AdAAuIB0wDQYJKoZIhvcNAQELBQADggIB',
'# AAfmiFEN4sbgmD+BcQM9naOhIW+z66bM9TG+zwXiqf76V20ZMLPCxWbJat/15/B4',
'# vceoniXj+bzta1RXCCtRgkQS+7lTjMz0YBKKdsxAQEGb3FwX/1z5Xhc1mCRWS3Tv',
'# QhDIr79/xn/yN31aPxzymXlKkVIArzgPF/UveYFl2am1a+THzvbKegBvSzBEJCI8',
'# z+0DpZaPWSm8tv0E4XCfMkon/VWvL/625Y4zu2JfmttXQOnxzplmkIz/amJ/3cVK',
'# C5Em4jnsGUpxY517IW3DnKOiPPp/fZZqkHimbdLhnPkd/DjYlPTGpQqWhqS9nhqu',
'# BEKDuLWAmyI4ILUl5WTs9/S/fmNZJQ96LjlXdqJxqgaKD4kWumGnEcua2A5HmoDF',
'# 0M2n0O99g/DhO3EJ3110mCIIYdqwUB5vvfHhAN/nMQekkzr3ZUd46PioSKv33nJ+',
'# YWtvd6mBy6cJrDm77MbL2IK0cs0d9LiFAR6A+xuJKlQ5slvayA1VmXqHczsI5pgt',
'# 6o3gMy4SKfXAL1QnIffIrE7aKLixqduWsqdCosnPGUFN4Ib5KpqjEWYw07t0Mkvf',
'# Y3v1mYovG8chr1m1rtxEPJdQcdeh0sVV42neV8HR3jDA/czmTfsNv11P6Z0eGTgv',
'# vM9YBS7vDaBQNdrvCScc1bN+NR4Iuto229Nfj950iEkSoYIDdjCCAl4CAQEwgeOh',
'# gbmkgbYwgbMxCzAJBgNVBAYTAlVTMRMwEQYDVQQIEwpXYXNoaW5ndG9uMRAwDgYD',
'# VQQHEwdSZWRtb25kMR4wHAYDVQQKExVNaWNyb3NvZnQgQ29ycG9yYXRpb24xDTAL',
'# BgNVBAsTBE1PUFIxJzAlBgNVBAsTHm5DaXBoZXIgRFNFIEVTTjpCMUI3LUY2N0Yt',
'# RkVDMjElMCMGA1UEAxMcTWljcm9zb2Z0IFRpbWUtU3RhbXAgU2VydmljZaIlCgEB',
'# MAkGBSsOAwIaBQADFQA6ut+TKGXketPno/bip0RuWKpT0qCBwjCBv6SBvDCBuTEL',
'# MAkGA1UEBhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1v',
'# bmQxHjAcBgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjENMAsGA1UECxMETU9Q',
'# UjEnMCUGA1UECxMebkNpcGhlciBOVFMgRVNOOjRERTktMEM1RS0zRTA5MSswKQYD',
'# VQQDEyJNaWNyb3NvZnQgVGltZSBTb3VyY2UgTWFzdGVyIENsb2NrMA0GCSqGSIb3',
'# DQEBBQUAAgUA3s0csTAiGA8yMDE4MDYxNTAwNTYxN1oYDzIwMTgwNjE2MDA1NjE3',
'# WjB0MDoGCisGAQQBhFkKBAExLDAqMAoCBQDezRyxAgEAMAcCAQACAgveMAcCAQAC',
'# AhsiMAoCBQDezm4xAgEAMDYGCisGAQQBhFkKBAIxKDAmMAwGCisGAQQBhFkKAwGg',
'# CjAIAgEAAgMW42ChCjAIAgEAAgMHoSAwDQYJKoZIhvcNAQEFBQADggEBAIZUN3Ad',
'# uKRnCEUSvfuGVv3ZVzy88kRCB45J5MbvHy5BDGSQ0tbf2z0VwF8mzCttrKxAD2Ds',
'# K+npj5LO4g7OEOdHkLQqYchTNt8bL/o+l+TB8vtTiAjPMpAhdjhDQoaCekXaWAVA',
'# goSKllIZIRCFsAz6GyPaMAF0x+UTQaclAMNmUqiEpmW07nWet1ESHc7YBuIfutcE',
'# 1cxe8p2YDNyhJhSTr4j5z74AlnC31XBLs+2fFWSsLl5pgULpfYj4OG2FXRwyhJTp',
'# 0ALDrqaj5Il0juCNquNut4UVTQZoUC4rkudHtMjrlcOBZj9FXtJMbnz5CEFPsgik',
'# q/coy+KcMpQ6vTkxggL1MIIC8QIBATCBkzB8MQswCQYDVQQGEwJVUzETMBEGA1UE',
'# CBMKV2FzaGluZ3RvbjEQMA4GA1UEBxMHUmVkbW9uZDEeMBwGA1UEChMVTWljcm9z',
'# b2Z0IENvcnBvcmF0aW9uMSYwJAYDVQQDEx1NaWNyb3NvZnQgVGltZS1TdGFtcCBQ',
'# Q0EgMjAxMAITMwAAALFxE3nfdfY1yAAAAAAAsTANBglghkgBZQMEAgEFAKCCATIw',
'# GgYJKoZIhvcNAQkDMQ0GCyqGSIb3DQEJEAEEMC8GCSqGSIb3DQEJBDEiBCAo65EN',
'# TaZ7PVKT0u3v7TN4r9JEBDc+B+JLeCMN+4K+bTCB4gYLKoZIhvcNAQkQAgwxgdIw',
'# gc8wgcwwgbEEFDq635MoZeR60+ej9uKnRG5YqlPSMIGYMIGApH4wfDELMAkGA1UE',
'# BhMCVVMxEzARBgNVBAgTCldhc2hpbmd0b24xEDAOBgNVBAcTB1JlZG1vbmQxHjAc',
'# BgNVBAoTFU1pY3Jvc29mdCBDb3Jwb3JhdGlvbjEmMCQGA1UEAxMdTWljcm9zb2Z0',
'# IFRpbWUtU3RhbXAgUENBIDIwMTACEzMAAACxcRN533X2NcgAAAAAALEwFgQUHHMu',
'# v8U/ay/8douP3d5VUq2Y1hIwDQYJKoZIhvcNAQELBQAEggEAM/B+VmZxC/P3tQXF',
'# DPILmFrWKUM5En7SBGio1VJktZLif/BPt0WeIri1y5zmsyR/2ng8kHIJ3V4NC2sG',
'# bUjchcGioFktIS0lI4m5mj14r22SCvOf9WG1bkgEWwtLEiYQKKtHlGDoIL5IIPMR',
'# sPQry2c2ooKjJoxbJdVCoKZLF6qemCf1YBtgqUej5Jn9GVchNK1bkM+/wc4FpzGP',
'# cVSs0oHjOyC5XV33gUItp+bcyjEvssXByI5qr/kjPzL5hoXPMkPt1THhwEDzpCbp',
'# XaLanxGashfZRX3+AwsPZxVNQxT75lL7jh8G3ZkHVZ+nfEQBhEigMFWJ9QLxc3cx',
'# U2KO5Q==',
'# SIG # End signature block'
)

$patchApprovalListTXTfile =( 
'KB2894852',
'KB2919355',
'KB2966826',
'KB2966828',
'KB2968296',
'KB2972103',
'KB2973201',
'KB2976897',
'KB3000483',
'KB3004365',
'KB3010788',
'KB3011780',
'KB3019978',
'KB3021674',
'KB3023219',
'KB3023266',
'KB3035126',
'KB3037576',
'KB3045685',
'KB3045755',
'KB3045999',
'KB3046017',
'KB3055642',
'KB3059317',
'KB3061512',
'KB3071756',
'KB3072307',
'KB3074545',
'KB3082089',
'KB3084135',
'KB3086255',
'KB3097992',
'KB3109103',
'KB3110329',
'KB3126434',
'KB3126587',
'KB3127222',
'KB3133043',
'KB3139398',
'KB3139914',
'KB3146723',
'KB3155784',
'KB3156059',
'KB3159398',
'KB3161949',
'KB3162343',
'KB3172729',
'KB3175024',
'KB3178539',
'KB3173424',
'KB2913695',
'KB2967917',
'KB3000850',
'KB3013769',
'##Malicious Software Removal Kit',
'KB890830',
'##WMF 5.1 and .NET FW 4.7.1',
'KB4033369',
'KB4033393',
'KB3191564',
'##June 2018 Server 2012 R2',
'KB4099635',
'KB4284815',
'##June 2018 Server 2016',
'KB4091664',
'KB4284880',
'KB4132216',
'KB4287903'
)

if ((test-path -Type Leaf -Path "$tempDir\Invoke WSUS Cleanup.xml") -eq $False){
$invokeWSUSCleanupXMLfile | % {$_ | out-file "$tempDir\Invoke WSUS Cleanup.xml" -append}
}

if ((test-path -Type Leaf -Path "$tempDir\WSUS-SQLIndexes.ps1") -eq $False){
$WSUSSQLIndexesPSfile | % {$_ | out-file "$tempDir\WSUS-SQLIndexes.ps1" -append}
}

if ((test-path -Type Leaf -Path "$tempDir\ApproveWSUSPatches.ps1") -eq $False){
$approveWSUSpatchPSfile | % {$_ | out-file "$tempDir\ApproveWSUSPatches.ps1" -append}
}

if ((test-path -Type Leaf -Path "$tempDir\PatchApprovalList.txt") -eq $False){
$patchApprovalListTXTfile| % {$_ | out-file "$tempDir\PatchApprovalList.txt" -append}
}

cls
remove-job *
$error.clear()

$sid = [Security.Principal.SecurityIdentifier]'S-1-5-20'
$usrsid = [Security.Principal.SecurityIdentifier]'S-1-5-32-545'
$user= ((whoami).split("\") | select -last 1)
$splashScreen
 
if ($RepViewer -eq $True){

write-host -nonewline "$($o[9]) $($o[11]) $($o[0]) "
$URL = 'https://download.microsoft.com/download/F/B/7/FB728406-A1EE-4AB5-9C56-74EB8BDDF2FF/ReportViewer.msi'
Start-BitsTransfer $URL $tempDir -RetryInterval 60 -RetryTimeout 180 -ErrorVariable err

if(!($err)){

write-host -f Cyan "$($o[3])"

} else {write-host "$($o[88])" -f Red}

if($err){

write-host "+$($o[11]) $($o[12]) $($o[21]) $($o[13]) $($o[3])!" -f Yellow
write-host "+$($o[1]) $($o[2]) $($o[4]) $($o[5]) $($o[14]) $($o[16]) $($o[18]) $($o[22]) $($o[24]) $($o[25])" -f Yellow

}

}

if ($SqlSysClr -eq $True){

write-host -nonewline "$($o[9]) $($o[28]) $($o[0]) "
#Invoke-WebRequest -Uri
#http://go.microsoft.com/fwlink/?linkID=239644&clcid=0x409
#$URL = "https://download.microsoft.com/download/8/7/2/872BCECA-C849-4B40-8EBE-21D48CDF1456/ENU/x64/SQLSysClrTypes.msi"
$URL = 'http://go.microsoft.com/fwlink/?linkID=239644&clcid=0x409'
Invoke-WebRequest -Uri $URL -OutFile "$tempDir\SqlSysClrTypes.msi" -ErrorVariable err

if(!($err)){

write-host -f Cyan "$($o[3])"

}else{

    write-host "$($o[88])" -f Red
}

if ($err){

write-host "+$($o[27]) $($o[12]) $($o[21]) $($o[13]) $($o[3])!" -f Yellow
write-host "+$($o[1]) $($o[2]) $($o[4]) $($o[5]) $($o[14]) $($o[16]) $($o[18]) $($o[22]) $($o[27])" -f Yellow
#write-host "$($o[26])" -f Magenta

}

}

if ($SqlSysClr -eq $True){

write-host -nonewline "$($o[6]) $($o[28]) $($o[0]) "
#Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList "/i `"<path\to\installer.msi>`" /qn"
$setup=Start-Process "$env:systemroot\system32\msiexec.exe" -ArgumentList "/i `"$tempDir\SqlSysClrTypes.msi`" /qn" -Wait -PassThru
#$setup=Start-Process "$tempDir\ReportViewer.msi" -verb RunAs -ArgumentList '/q' -Wait -PassThru

if ($setup.exitcode -eq 0){

write-host -f Cyan "$($o[7])"

}else{

write-host -f "$o[88].." -f Red
write-host "+$($o[27]) $($o[20]) $($o[21]) $($o[5]) $($o[23])" -f Yellow
write-host "+$($o[1]) $($o[2]) $($o[4]) $($o[5]) $($o[14]) $($o[16]) $($o[18]) $($o[22]) $($o[27])" -f Yellow

}
}

if ($RepViewer -eq $True){

write-host -nonewline "$($o[6]) $($o[89]) $($o[0]) "
#Start-Process -FilePath "$env:systemroot\system32\msiexec.exe" -ArgumentList "/i `"<path\to\installer.msi>`" /qn"
$setup=Start-Process "$env:systemroot\system32\msiexec.exe" -ArgumentList "/i `"$tempDir\ReportViewer.exe`" /qn" -Wait -PassThru
#$setup=Start-Process "$tempDir\ReportViewer.msi" -verb RunAs -ArgumentList '/q' -Wait -PassThru

if ($setup.exitcode -eq 0){

write-host -f Cyan "$($o[7])"

}else{

write-host -f Red "$($o[88])"
write-host "+$($o[11]) $($o[20]) $($o[21]) $($o[5]) $($o[23])" -f Yellow
write-host "+$($o[2]) $($o[4]) $($o[5]) $($o[14]) $($o[16]) $($o[18]) $($o[22]) $($o[24]) $($o[26])" -f Yellow


}
}

if ($wid_WSUS -eq 'WID'){  
write-host -nonewline "$($o[6]) $($o[24]) $($o[19]) ($($o[81]) $($o[82])) $($o[0]) "

if(((Get-WindowsFeature -Name UpdateServices | select *).InstallState) -ne 'Installed') {

Install-WindowsFeature -Name UpdateServices -IncludeManagementTools 2>&1 | out-file _$.0

write-host -f cyan "$($o[7])"

CountDown -waitMinutes -Statlabel "System will reboot the WUSServer in 1 min. Rerun the script after the reboot!"
Restart-Computer

} else {write-host -f green "$($o[90]) $($o[7])"}

}
 
if ($wid_WSUS -eq 'WID')
{ 

#Post install has successfully completed
write-host -nonewline "$($o[91]) $($o[93]) $($o[92]) "

$user= ((whoami).split("\") | select -last 1)

$job = Start-Job -Name Postinstallation -ScriptBlock {

param ($wsusDirPath)

#Install-WindowsFeature UpdateServices -Restart
sl "C:\Program Files\Update Services\Tools"
.\wsusutil.exe postinstall CONTENT_DIR=$wsusDirPath 2>&1 | out-file postinstallation.log
sl "C:\users\$user\desktop"

} -ArgumentList $wsusDirPath

while (((get-job -name Postinstallation).state) -eq 'Running'){

    write-host -nonewline -f DarkGray ".";sleep 6

} 

$log = get-content 'C:\Program Files\Update Services\Tools\postinstallation.log'

del 'C:\Program Files\Update Services\Tools\postinstallation.log'
Remove-Job -name Postinstallation

if($log -contains "Post install has successfully completed"){

    write-host -f cyan " $($o[7])"

    }else{
        write-host -f Red " $($o[88])"

        uninstall-windowsfeature -name windows-internal-database
        uninstall-WindowsFeature -Name UpdateServices -IncludeManagementTools

        install-windowsfeature -name windows-internal-database
        Install-WindowsFeature -Name UpdateServices -IncludeManagementTools

    }

}

$wsus = Get-WSUSServer
$wsusConfig = $wsus.GetConfiguration()
 
$null=Set-WsusServerSynchronization â€“SyncFromMU
 
$wsusConfig.AllUpdateLanguagesEnabled = $false
$wsusConfig.SetEnabledUpdateLanguages("en")
$null=$wsusConfig.Save()

$subscription = $wsus.GetSubscription()
$null=$subscription.StartSynchronizationForCategoryOnly()

write-host -nonewline "$($o[8]) $($o[24]) $($o[30]) $($o[38]) $($o[31]) $($o[32]) $($o[33])"
#write-host "$($o[35]) $($o[36]) $($o[37]) $($o[38]) $($o[39])"

While ($subscription.GetSynchronizationStatus() -ne 'NotProcessing') {
    Write-Host -f DarkGray "." -NoNewline
    Start-Sleep -Seconds 25
}

if($subscription.GetSynchronizationStatus() -eq 'NotProcessing'){write-host -f cyan " $($o[94])"}

#Write-Host "$($o[30]) $($o[15]) $($o[39])" -f Green

write-host -nonewline "$($o[10]) $($o[24]) $($o[33]) $($o[0]) "

Get-WsusProduct | where-Object {
    $_.Product.Title -in (
    'ASP.NET Web Frameworks',
    'Developer Tools, Runtimes, and Redistributables',
    'Forefront Endpoint Protection 2010',
    'Microsoft Application Virtualization 4.5',
    'Microsoft Application Virtualization 4.6',
    'Microsoft Application Virtualization 5.0',
    'Microsoft Monitoring Agent',
    'Microsoft System Center DPM 2010',
    'Microsoft Application Virtualization',
    'Network Monitor',
    'SDK Components',
    'Network Monitor 3',
    'Office 2003',
    'Office 2007',
    'Office 2010',
    'Office 2013',
    'Office 2016',
    'CAPICOM',
    'Silverlight',
    'Microsoft SQL Server 2012',
    'Microsoft SQL Server 2014',
    'Microsoft SQL Server 2016',
    'Microsoft SQL Server 2017',
    'Microsoft SQL Server Management Studio v17',
    'SQL Server 2012 Product Updates for Setup',
    'SQL Server 2014-2016 Product Updates for Setup',
    'System Center 2012 R2 - Data Protection Manager',
    'System Center Configuration Manager 2007',
    'Windows 10 LTSB',
    'Windows Defender',
    'Windows Server 2012 R2',
    'Windows Server 2012 R2  and later drivers',
    'Windows Server 2016',
    'Windows Server 2016 and Later Servicing Drivers',
    'Windows Server Manager â€“ Windows Server Update Services (WSUS) Dynamic Installer',
    'Developer Tools, Runtimes, and Redistributables, Report Viewer 2005',
    'Developer Tools, Runtimes, and Redistributables, Report Viewer 2008',
    'Developer Tools, Runtimes, and Redistributables, Report Viewer 2010',
    'Developer Tools, Runtimes, and Redistributables, Visual Studio 2005',
    'Developer Tools, Runtimes, and Redistributables, Visual Studio 2008',
    'Developer Tools, Runtimes, and Redistributables, Visual Studio 2010',
    'Developer Tools, Runtimes, and Redistributables, Visual Studio 2010 Tools for Office Runtime',
    'Developer Tools, Runtimes, and Redistributables, Visual Studio 2012',
    'Developer Tools, Runtimes, and Redistributables, Visual Studio 2013'
    )
} | Set-WsusProduct

sleep 1;write-host -f cyan "$($o[95]) "

# Configure the Classifications
write-host -nonewline "$($o[10]) $($o[24]) $($o[34]) $($o[34]) $($o[0]) "
Get-WsusClassification | Where-Object {
    $_.Classification.Title -in (
    'Critical Updates',
    'Definition Updates',
    'Feature Packs',
    'Hotfix',
    'Security Updates',
    'Service Packs',
    'Tools',
    'Update Rollups',
    'Updates',
    'Upgrades'
    )
} | Set-WsusClassification

sleep 1;write-host -f cyan "$($o[95])"

# Prompt to check products are set correctly
write-host "$($o[41]) $($o[96]), $($o[1]) $($o[40]) $($o[42]) $($o[24]) $($o[43]), $($o[44]) $($o[42]) $($o[24]) $($o[45]) $($o[47]),"-f Yellow
write-host "$($o[48]) $($o[18]) $($o[49]) > $($o[33]) $($o[4]) $($o[34]), $($o[4]) $($o[50]) $($o[51]) $($o[42]) $($o[33]) $($o[52]) $($o[53]) $($o[23])" -f Gray
write-host -nonewline "$($o[97]) $($o[98]) $($o[0]) " -f Yellow

$Shell = New-Object -ComObject "WScript.Shell"
$Button = $Shell.Popup("$($o[10]) $($o[84]) $($o[38]) $($o[72])", 0, "$($o[97]) $($o[98])", 0) # Using Pop-up in case script is running in ISE

sleep 1;write-host -f Gray "$($o[99]) $($o[97])"

# Configure Synchronizations
write-host -nonewline "$($o[54]) $($o[24]) $($o[55]) $($o[56]) $($o[56]) "
$subscription.SynchronizeAutomatically=$true
 
# Set synchronization scheduled for midnight each night
$subscription.SynchronizeAutomaticallyTimeOfDay= (New-TimeSpan -Hours 0)
$subscription.NumberOfSynchronizationsPerDay=12
$subscription.Save()

if (($subscription.NumberOfSynchronizationsPerDay) -eq 12){

write-host -f Cyan "$($o[100])"

} else {write-host -f Red "$($o[88])"}

# Kick off a synchronization
$subscription.StartSynchronization()

# Monitor Progress of Synchronisation
 
write-host -nonewline "$($o[85]) $($o[24]) $($o[30]), $($o[35]) $($o[36]) $($o[37]) $($o[0]) "
Start-Sleep -Seconds 60 
while ($subscription.GetSynchronizationProgress().ProcessedItems -ne $subscription.GetSynchronizationProgress().TotalItems) {
    Write-Progress -PercentComplete (
    $subscription.GetSynchronizationProgress().ProcessedItems*100/($subscription.GetSynchronizationProgress().TotalItems)
    ) -Activity "$($o[24]) $($o[30]) $($o[62])"
}

Write-Host "$($o[30]) $($o[15]) $($o[39])" -f Cyan

if ($declineUpdates -eq $True)
{
write-host "$($o[59]) $($o[60]) $($o[61])"
$approveState = 'Microsoft.UpdateServices.Administration.ApprovedStates' -as [type]
 
# Declining All Internet Explorer 10
$updateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope -Property @{
    TextIncludes = '0000000'
    ApprovedStates = $approveState::Any
}
$wsus.GetUpdates($updateScope) | ForEach {
    Write-Verbose ("$($o[59]) {0}" -f $_.Title) -Verbose
    $_.Decline()
}
 
# Declining Microsoft Browser Choice EU
$updateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope -Property @{
    TextIncludes = '0000000'
    ApprovedStates = $approveState::Any
}
$wsus.GetUpdates($updateScope) | ForEach {
    Write-Verbose ("$($o[59]) {0}" -f $_.Title) -Verbose
    $_.Decline()
}
 
# Declining all Itanium Update
$updateScope = New-Object Microsoft.UpdateServices.Administration.UpdateScope -Property @{
    TextIncludes = 'itanium'
    ApprovedStates = $approveState::Any
}
$wsus.GetUpdates($updateScope) | ForEach {
    Write-Verbose ("$($o[59]) {0}" -f $_.Title) -Verbose
    $_.Decline()
}

}

# Configure Default Approval Rule
 
if ($definitionApprov -eq $True)
{
write-host -NoNewline "$($o[128]) $($o[127]) $($o[64]) $($o[0]) "
[void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")

$rule = $wsus.GetInstallApprovalRules() | Where {$_.Name -eq "Auto Update Definition Updates"}

if($rule -eq $null){

$newRule = $wsus.CreateInstallApprovalRule("Auto Update Definition Updates") 
$rule = $wsus.GetInstallApprovalRules() | Where {
    $_.Name -eq "Auto Update Definition Updates"}

$class = $wsus.GetUpdateClassifications() | ? {$_.Title -In (
    'Critical Updates',
    'Definition Updates',
    'Security Updates',
    'Updates',
    'Upgrades'
    )}

$class2 = $wsus.GetUpdateCategories() | ? {$_.Title -In (
    'Forefront Endpoint Protection 2010',
    'Windows Defender'
    )}

$class_coll = New-Object Microsoft.UpdateServices.Administration.UpdateClassificationCollection
$class_coll2 = New-Object Microsoft.UpdateServices.Administration.UpdateCategoryCollection
$class_coll.AddRange($class)
$class_coll2.AddRange($class2)

$rule.SetUpdateClassifications($class_coll)
$rule.Enabled = $True

$rule.SetCategories($class_coll2)

$rule.Save()
}
}

write-host -f Cyan "$($o[100])"
 
if ($rundefRule -eq $True)
{
write-host -nonewline "$($o[129]) $($o[127]) $($o[64]) $($o[0]) "
write-host -nonewline -f yellow "> $($o[14]) $($o[35]) $($o[36]) $($o[37]) $($o[0]) " 
try {
    if ($rule -eq $null)
{
$Apply = $rule.ApplyRule()
}
}
catch {
write-warning $_
}
Finally {

}
Write-Host "$($o[133])" -f Cyan
}

if ($minorApprov -eq $True)
{
write-host -NoNewline "$($o[128]) $($o[130]) & $($o[131]) $($o[132]) $($o[0]) "
[void][reflection.assembly]::LoadWithPartialName("Microsoft.UpdateServices.Administration")
$rule = $wsus.GetInstallApprovalRules() | Where {$_.Name -eq "Security Updates auto approve minor Components"}

if($rule -eq $null){

$newRule = $wsus.CreateInstallApprovalRule("Security Updates auto approve minor Components") 
$rule = $wsus.GetInstallApprovalRules() | Where {
    $_.Name -eq "Security Updates auto approve minor Components"}

$class = $wsus.GetUpdateClassifications() | ? {$_.Title -In (
    'Critical Updates',
    'Security Updates'
    )}

$class2 = $wsus.GetUpdateCategories() | ? {$_.Title -In (
    'ASP.NET Web and Data Frameworks',
    'Developer Tools,Runtimes, and Redistributables',
    'Forefront Endpoint Protection 2010',
    'Microsoft Monitoring Agent (MMA)',
    'Office 2007',
    'Office 2010',
    'Office 2013',
    'Office 2016',
    'Office 365 Client',
    'SDK Components',
    'Siliverlight'
    )}

$class_coll = New-Object Microsoft.UpdateServices.Administration.UpdateClassificationCollection
$class_coll2 = New-Object Microsoft.UpdateServices.Administration.UpdateCategoryCollection
$class_coll.AddRange($class)
$class_coll2.AddRange($class2)

$rule.SetUpdateClassifications($class_coll)
$rule.Enabled = $True

$rule.SetCategories($class_coll2)

$rule.Save()
}
}

write-host -f Cyan "$($o[100])"

if ($rule -eq $null)
{
write-host -nonewline "$($o[129]) $($o[131]) $($o[132]) $($o[64]) $($o[0])"
write-host -nonewline -f yellow "> $($o[14]) $($o[35]) $($o[36]) $($o[37]) $($o[0]) "
try {
    if ($definitionApprov -eq $True)
{
$Apply = $rule.ApplyRule()
}
}
catch {
write-warning $_
}
Finally {

}
Write-Host "$($o[133])" -f Cyan
}

write-host -nonewline "$($o[54]) $($o[134]) $($o[19]) $($o[24]) $($o[0]) "
$enabledownloadexpress = (Get-WsusServer).GetConfiguration()

if($enabledownloadexpress.DownloadExpressPackages -ne $True){

write-host -nonewline -f yellow "$($o[15]) $($o[21]) $($o[135]) $($o[0]) "

$enabledownloadexpress.DownloadExpressPackages = $true
$enabledownloadexpress.Save()

sleep 1 
write-host -f cyan "$($o[133])"
}else{write-host -f green "$($o[15]) $($o[90]) $($o[135])"}

$modulels=(Get-Module).Name
write-host -nonewline "$($o[101]) $($o[102]) $($o[103]) $($o[0]) "

if ($modulels -notcontains "IISAdministration"){

sleep 1
write-host -nonewline -f Yellow "$($o[21]) $($o[79]) $($o[0]) "

Import-Module WebAdministration

write-host -f Cyan "$($o[95])"

    }else{write-host -f Cyan "$($o[90]) $($o[95])" }

write-host -nonewline "$($o[10]) $($o[24]) $($o[104]) $($o[0]) "
#$WsusPool = Get-ItemProperty IIS:\AppPools\WsusPool
$poolls = (Get-ItemProperty IIS:\AppPools\*).Name

if ($poolls-contains "WsusPool"){
$WsusPool=(Get-ItemProperty IIS:\AppPools\WsusPool\)
sleep 1
write-host -nonewline -f Yellow "$($o[105]) "
sleep 1
$prequlg=(Get-ItemProperty IIS:\AppPools\WsusPool\).queueLength

write-host -nonewline "+$($o[10]) $($o[24]) $($o[104]) $($o[106]) $($o[107]) $prequlg $($o[18]) 25000 $($o[0]) "
Set-ItemProperty -Path $WsusPool.PSPath -Name queueLength -Value 25000
sleep 1
write-host -f Cyan "$($o[39]) "

write-host -nonewline "+$($o[10]) $($o[24]) $($o[104]) $($o[108]) $($o[0]) "
$prelbcapa=get-webconfigurationproperty /system.applicationHost/applicationPools/applicationPoolDefaults[1]/failure[1] -name loadBalancerCapabilities
sleep 1

if($prelbcapa -ne 'TcpLevel'){

write-host -nonewline -f yellow "$($o[53]) $($o[18]) $prelbcapa $($o[0]) "
set-webconfigurationproperty /system.applicationHost/applicationPools/applicationPoolDefaults[1]/failure[1] -name loadBalancerCapabilities -value 1
sleep 1
write-host -f Cyan "$($o[109]) $($o[53])"

    }else {write-host -f Cyan "$($o[109]) $($o[53])"}

write-host -nonewline "+$($o[10]) $($o[24]) $($o[110]) $($o[111]) $($o[112]) $($o[0]) "
$prefailInterval=get-webconfigurationproperty /system.applicationHost/applicationPools/applicationPoolDefaults[1]/failure[1] -name rapidFailProtectionInterval
sleep 1
if (($prefailInterval).value -le '00:59:00'){

sleep 1
write-host -nonewline -f yellow "$($o[15]) $($o[53]) $($o[18]) $($o[113]) $($o[114]) 60 $($o[0])"
set-webconfigurationproperty /system.applicationHost/applicationPools/applicationPoolDefaults[1]/failure[1] -name rapidFailProtectionInterval -value '01:00:00'
sleep 1
write-host -f Cyan "$($o[53]) $($o[38]) 60"
    }else{write-host -f green "$($o[15]) $($o[90]) $($o[53]) $($o[18]) 60"}    


write-host -nonewline "+$($o[10]) $($o[24]) $($o[116]) $($o[0]) "
$prefailMaxCrash=get-webconfigurationproperty /system.applicationHost/applicationPools/applicationPoolDefaults[1]/failure[1] -name rapidFailProtectionMaxCrashes
sleep 1
if (($prefailMaxCrash).value -le '99'){

write-host -nonewline -f yellow "$($o[15]) $($o[53]) $($o[18]) $($prefailMaxCrash.value) $($o[0]) "
sleep 1
set-webconfigurationproperty /system.applicationHost/applicationPools/applicationPoolDefaults[1]/failure[1] -name rapidFailProtectionMaxCrashes -value 100
write-host -f green "$($o[15]) $($o[117]) $($o[53]) $($o[38]) 100"

    }else{write-host -f green "$($o[15]) $($o[90]) $($o[53]) $($o[38]) 100"}

write-host -nonewline "+$($o[10]) $($o[24]) $($o[118])$($o[119]) $($o[0]) "

$applicationPoolsPath = "/system.applicationHost/applicationPools"
$applicationPools = Get-WebConfiguration $applicationPoolsPath

foreach ($appPool in $applicationPools.Collection)
{
if($appPool.Name -contains 'WsusPool'){
    $appPoolPath = "$applicationPoolsPath/add[@name='$($appPool.Name)']"
    $privateMem=Get-WebConfiguration "$appPoolPath/recycling/periodicRestart/@privateMemory" 
}
}
 
sleep 1
if (($privateMem).value -le '5900000'){

write-host -nonewline -f yellow "$($o[15]) $($o[53]) $($o[18]) $($privateMem.value) $($o[0]) "
sleep 1    

Set-WebConfiguration "$appPoolPath/recycling/periodicRestart/@privateMemory" -Value 6000000

write-host -f green "$($o[15]) $($o[117]) $($o[53]) $($o[38]) 6000000"

    }else{write-host -f green "$($o[15]) $($o[90]) $($o[53]) $($o[38]) 6000000"}


} else{write-host -f red "$($o[24]) $($o[21]) $($o[105])"}

write-host -nonewline "$($o[122]) $($o[123]) $($o[124]) '$($o[120])\$($o[121])' $($o[18]) $wsusDirPath $($o[0]) "

$acl = (Get-Item $wsusDirPath).GetAccessControl('Access') 
$usersls=(($acl.access).IdentityReference).Value
sleep 1

if($usersls -NotContains 'NT AUTHORITY\NETWORK SERVICE'){    

write-host -nonewline "'$($o[120])\$($o[121])' $($o[21]) $($o[105]) $($o[0]) "

$acct = $sid.Translate([Security.Principal.NTAccount]).Value

$acl = (Get-Item $wsusDirPath).GetAccessControl('Access') 

$Ar = New-Object Security.AccessControl.FileSystemAccessRule($acct, 'Modify', 'ContainerInherit,ObjectInherit', 'None', 'Allow')

$acl.SetAccessRule($Ar)

$usersls=(($acl.access).IdentityReference).Value

Set-Acl $wsusDirPath $acl

if($usersls -Contains 'NT AUTHORITY\NETWORK SERVICE'){

    write-host -f cyan "$($o[125])"

    }else{write-host -f red "$($o[88])"}

}else{write-host -f green "$($o[15]) $($o[90]) $($o[105])"}


write-host -nonewline "$($o[126]) $($o[136]) $($o[19]) $($o[137]) $($o[0]) "
$schtaskls=(Get-ScheduledTask).TaskName

if($schtaskls -NotContains 'Invoke WSUS Cleanup'){

$null = schtasks.exe /create /RU "NT AUTHORITY\SYSTEM" /TN 'Invoke WSUS Cleanup' /XML 'C:\$_.temp.jjs.workflow\Invoke WSUS Cleanup.xml'

write-host -f cyan "$($o[125])"

} else {write-host -f green "$($o[15]) $($o[90]) $($o[105])"}


write-host -nonewline "$($o[54]) $($o[138]) $($o[19]) $($o[42]) $($o[124]) $($o[0]) "
$UserKey = "HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}"
$userkeyis= (Get-ItemProperty -Path $UserKey -Name "IsInstalled").IsInstalled

if($userkeyis -eq 0){
    
$null=Set-ItemProperty -Path $UserKey -Name "IsInstalled" -Value 1
$null=Stop-Process -Name Explorer

$userkeyis= (Get-ItemProperty -Path $UserKey -Name "IsInstalled").IsInstalled

if($userkeyis -eq 1){

sleep 1
write-host -f cyan "$($o[135])"

}else{write-host -f red "$($o[88])"}

    }else{write-host -f green "$($o[15]) $($o[90]) $($o[139])"}


write-host -nonewline "$($o[126]) $($o[24]) $($o[140]) $($o[141]) D:\ $($o[0]) "

if((test-path -path D:\PatchApprovals) -eq $false){

mkdir D:\PatchApprovals 2>&1 | out-file _$.0
copy $tempdir\ApproveWSUSPatches.ps1 D:\PatchApprovals\ApproveWSUSPatches.ps1
copy $tempdir\PatchApprovalList.txt D:\PatchApprovals\PatchApprovalList.txt

write-host -f cyan "$($o[125])"

} else {write-host -f green "$($o[15]) $($o[90]) $($o[105])"}

$acl = Get-Acl -Path "D:\PatchApprovals\"
$usrAccess=($acl | select *)
$usrRight=($usrAccess.Access | where-object {$_.IdentityReference -like "*Users*"}).FileSystemRights

write-host -nonewline "$($o[10]) $($o[142]) $($o[143]) $($o[19]) D:\$($o[140]) $($o[0]) "
sleep 1
if($usrRight -NotContains 'Modify'){

write-host -nonewline -f yellow "$($o[15]) $($o[21]) $($o[53]) $($o[0]) "
sleep 1

$Ar = New-Object system.security.accesscontrol.filesystemaccessrule('Users', 'Modify', "ContainerInherit,ObjectInherit", "None", 'Allow')
$acl.SetAccessRuleProtection($True, $True)
$acl.SetAccessRule($Ar)
$null=Set-Acl -Path "D:\PatchApprovals\" -AclObject $acl

write-host -f cyan "$($o[133])"

}else{write-host -f green "$($o[15]) $($o[90]) $($o[105])"}

write-host "$($o[73]) $($o[74]) $($o[75])"
if (Test-Path $tempDir\ReportViewer.exe)
{Remove-Item $tempDir\ReportViewer.exe -Force}
if (Test-Path $tempDir\SQLEXPRWT_x64_ENU.exe)
{Remove-Item $tempDir\SQLEXPRWT_x64_ENU.exe -Force}
If ($Tempfolder -eq "No")
{Remove-Item $tempDir -Force}
 
write-host "$($o[24]) $($o[76]) $($o[77]) $($o[78]) $($o[13]) $($o[79]) $($o[80]): %ProgramFiles%\Update Services\LogFiles"
write-host "$($o[39])!" -f Green

}


