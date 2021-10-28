<#

    Updates

		1.1.0 - 8/22/2017 - v-pemic
            -If script to be run in not in main folder will now check archive for last version there
			-If script is run from the archive folder it will set the script directory to the directory above the archive folder
			
		1.0.1 - 7/21/2017 - v-pemic
			-Removed "Title" property value as it was not working
			
		1.0.0 - 7/20/2017 - v-pemic
			-Adding versioning
			-Added logic to find latest version of script in the script path
			-Windows will now open with version info if available
	
#>

$ScriptDirectory = split-path $MyInvocation.MyCommand.path
if($ScriptDirectory -match "\\archive"){
    $cd = $ScriptDirectory.Replace("\archive", "")
    $ScriptDirectory = $cd}


$getLatestRTOTTS = Get-ChildItem $ScriptDirectory | Where-Object {$_.Name -match "Fairfax-RTO-TTStart-withBlocked"} | Sort-Object $_.Name -Descending
if(!($getLatestRTOTTS)){
    $getLatestRTOTTS = Get-ChildItem "$ScriptDirectory\archive" | Where-Object {$_.Name -match "Fairfax-RTO-TTStart-withBlocked"} | Sort-Object $_.Name -Descending
    $RTOTTSname = $getLatestRTOTTS[0].Name
    $RTOTTS = "archive\$RTOTTSname"
	}
else{
	$RTOTTS = $getLatestRTOTTS[0].Name}

$getLatestRDTTS = Get-ChildItem $ScriptDirectory | Where-Object {$_.Name -match "Fairfax-SCRAP"} | Sort-Object $_.Name -Descending
if(!($getLatestRDTTS)){
    $getLatestRDTTS = Get-ChildItem "$ScriptDirectory\archive" | Where-Object {$_.Name -match "Fairfax-RDTask-TTStart"} | Sort-Object $_.Name -Descending
    $RDTTSname = $getLatestRDTTS[0].Name
    $RDTTS = "archive\$RDTTSname"
	}
else{
	$RDTTS = $getLatestRDTTS[0].Name}

$getLatestRDTri = Get-ChildItem $ScriptDirectory | Where-Object {$_.Name -match "Fairfax-RDTask-All"} | Sort-Object $_.Name -Descending
if(!($getLatestRDTri)){
    $getLatestRDTri = Get-ChildItem "$ScriptDirectory\archive" | Where-Object {$_.Name -match "Fairfax-RDTask-Triage"} | Sort-Object $_.Name -Descending
    $RDTriname = $getLatestRDTri[0].Name
    $RDTri = "archive\$RDTriname"
	}
else{
	$RDTri = $getLatestRDTri[0].Name}



# Window Setup Variables
$Windows = @(
    
    # Upper Left
	@{ "X" = 0;  "Y" = 0; "X_SIZE" = 945;  "Y_SIZE" = 500; "Script" = ".\ICMLooper_New\IcmODataOperationsClient.exe WADE TimeToAcknowledge"}

    # Upper Right
	@{ "X" = 955; "Y" = 0; "X_SIZE" = 945;  "Y_SIZE" = 500; "Script" = ".\$RTOTTS" }

    # Lower Left
    @{ "X" = 0;  "Y" = 505; "X_SIZE" = 945;  "Y_SIZE" = 500; "Script" = ".\$RDTTS" }

    # Lower Right
    @{ "X" = 955; "Y" = 505; "X_SIZE" = 945;  "Y_SIZE" = 500; "Script" = ".\$RDTri" }

)


$ProcessManager = ([WMICLASS]"ROOT\CIMV2:Win32_Process")

Function isAdmin {
    [System.Security.Principal.WindowsPrincipal]$currentPrincipal = New-Object System.Security.Principal.WindowsPrincipal([System.Security.Principal.WindowsIdentity]::GetCurrent());
    [System.Security.Principal.WindowsBuiltInRole]$administratorsRole = [System.Security.Principal.WindowsBuiltInRole]::Administrator;
    return $currentPrincipal.IsInRole($administratorsRole)
}

Function Restart-Elevated {
    Start-Process "powershell.exe" -Verb Runas -ArgumentList " -file `"$($MyInvocation.ScriptName)`" n" -ErrorAction 'stop' 
    Exit
}

if (!(isAdmin)) {
    Restart-Elevated
}

foreach ($Window in $Windows) {

    $ProcessAttributes = ([WMICLASS]"ROOT\CIMV2:Win32_ProcessStartup")

    $ProcessAttributes.SetPropertyValue("X", $Window.X)
    $ProcessAttributes.SetPropertyValue("XSize", $Window.X_SIZE)
    $ProcessAttributes.SetPropertyValue("XCountChars", 100)

    $ProcessAttributes.SetPropertyValue("Y", $Window.Y)
    $ProcessAttributes.SetPropertyValue("YSize", $Window.Y_SIZE)
    $ProcessAttributes.SetPropertyValue("YCountChars", 2500)

    $ProcessManager.create("powershell -noexit $($Window.Script)", "$ScriptDirectory", $ProcessAttributes)

    Start-Sleep -Milliseconds 1000

}



